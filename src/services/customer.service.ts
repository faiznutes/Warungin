import { PrismaClient, Customer } from '@prisma/client';
import { CreateCustomerInput, UpdateCustomerInput, GetCustomersQuery } from '../validators/customer.validator';
import prisma from '../config/database';
import { getRedisClient } from '../config/redis';
import logger from '../utils/logger';

export class CustomerService {
  async getCustomers(tenantId: string, query: GetCustomersQuery) {
    const { page, limit, search, sortBy, sortOrder } = query;
    const skip = (page - 1) * limit;

    const where: any = {
      tenantId,
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const [customers, total] = await Promise.all([
      prisma.customer.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
        include: {
          _count: {
            select: {
              orders: true,
            },
          },
        },
      }),
      prisma.customer.count({ where }),
    ]);

    // Calculate total spent for each customer
    const customersWithStats = await Promise.all(
      customers.map(async (customer) => {
        const orders = await prisma.order.aggregate({
          where: {
            tenantId,
            customerId: customer.id,
            status: 'COMPLETED',
          },
          _sum: { total: true },
        });

        return {
          ...customer,
          totalSpent: Number(orders._sum.total || 0),
          totalOrders: customer._count.orders,
        };
      })
    );

    return {
      data: customersWithStats,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getCustomerById(id: string, tenantId: string): Promise<Customer | null> {
    return prisma.customer.findFirst({
      where: { id, tenantId },
      include: {
        orders: {
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: {
            items: {
              include: {
                product: true,
              },
            },
          },
        },
        _count: {
          select: {
            orders: true,
          },
        },
      },
    });
  }

  async createCustomer(data: CreateCustomerInput, tenantId: string): Promise<Customer> {
    try {
      const customer = await prisma.customer.create({
        data: {
          ...data,
          tenantId,
        },
      });

      // Invalidate analytics cache after customer creation
      await this.invalidateAnalyticsCache(tenantId);

      return customer;
    } catch (error: any) {
      // Log the error for debugging
      console.error('Prisma error in createCustomer:', error);
      // Re-throw with more context
      if (error.code === 'P1001' || error.code === 'P1002' || error.message?.includes('connect')) {
        throw new Error('Database connection failed. Please try again.');
      }
      throw error;
    }
  }

  async updateCustomer(id: string, data: UpdateCustomerInput, tenantId: string): Promise<Customer> {
    const customer = await this.getCustomerById(id, tenantId);
    if (!customer) {
      throw new Error('Customer not found');
    }

    const updatedCustomer = await prisma.customer.update({
      where: { id },
      data,
    });

    // Invalidate analytics cache after customer update
    await this.invalidateAnalyticsCache(tenantId);

    return updatedCustomer;
  }

  async deleteCustomer(id: string, tenantId: string): Promise<void> {
    const customer = await this.getCustomerById(id, tenantId);
    if (!customer) {
      throw new Error('Customer not found');
    }

    await prisma.customer.delete({
      where: { id },
    });

    // Invalidate analytics cache after customer deletion
    await this.invalidateAnalyticsCache(tenantId);
  }

  /**
   * Invalidate analytics cache for a tenant
   */
  private async invalidateAnalyticsCache(tenantId: string): Promise<void> {
    try {
      const redis = getRedisClient();
      if (redis) {
        // Delete all analytics cache keys for this tenant
        const keys = await redis.keys(`analytics:*:${tenantId}`);
        const keys2 = await redis.keys(`analytics:${tenantId}:*`);
        const allKeys = [...keys, ...keys2];
        if (allKeys.length > 0) {
          await redis.del(...allKeys);
          logger.info('Invalidated analytics cache after customer operation', {
            tenantId,
            cacheKeysDeleted: allKeys.length
          });
        }
      }
    } catch (error: any) {
      logger.warn('Failed to invalidate analytics cache', {
        error: error.message,
        tenantId
      });
    }
  }
}

export default new CustomerService();

