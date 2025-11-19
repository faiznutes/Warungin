import prisma from '../config/database';
import orderService from './order.service';

interface DeliveryOrder {
  id: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string;
  deliveryAddress: string;
  courier: string;
  trackingNumber?: string;
  status: string;
  createdAt: string;
}

interface CourierSetup {
  courier: string;
  apiKey: string;
}

class DeliveryService {
  async getDeliveryOrders(tenantId: string): Promise<DeliveryOrder[]> {
    // Get orders that have delivery information
    const orders = await prisma.order.findMany({
      where: {
        tenantId,
        // Only orders with delivery address or notes indicating delivery
        OR: [
          { notes: { contains: 'delivery', mode: 'insensitive' } },
          { notes: { contains: 'kurir', mode: 'insensitive' } },
        ],
      },
      include: {
        customer: {
          select: {
            name: true,
            phone: true,
            address: true,
          },
        },
        items: {
          include: {
            product: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 100,
    });

    return orders.map((order) => ({
      id: order.id,
      orderNumber: order.orderNumber,
      customerName: order.customer?.name || order.temporaryCustomerName || 'Guest',
      customerPhone: order.customer?.phone || '-',
      deliveryAddress: order.customer?.address || order.notes || '-',
      courier: this.extractCourierFromNotes(order.notes) || 'MANUAL',
      trackingNumber: this.extractTrackingFromNotes(order.notes),
      status: this.mapOrderStatusToDeliveryStatus(order.status),
      createdAt: order.createdAt.toISOString(),
    }));
  }

  async processDelivery(tenantId: string, orderId: string, data: { trackingNumber?: string; courier?: string }): Promise<any> {
    const order = await prisma.order.findFirst({
      where: {
        id: orderId,
        tenantId,
      },
    });

    if (!order) {
      throw new Error('Order not found');
    }

    // Update order notes with delivery info
    const notes = order.notes || '';
    const newNotes = [
      notes,
      data.courier ? `Courier: ${data.courier}` : '',
      data.trackingNumber ? `Tracking: ${data.trackingNumber}` : '',
    ]
      .filter(Boolean)
      .join(' | ');

    const updatedOrder = await prisma.order.update({
      where: { id: orderId },
      data: {
        notes: newNotes,
        status: 'PROCESSING',
      },
    });

    return updatedOrder;
  }

  async setupCourier(tenantId: string, data: CourierSetup): Promise<any> {
    // Store courier configuration in tenant settings or a separate table
    // For now, we'll just return success
    // In production, you'd store this in a courier_config table
    return {
      tenantId,
      courier: data.courier,
      status: 'active',
      configuredAt: new Date(),
    };
  }

  private extractCourierFromNotes(notes: string | null): string | null {
    if (!notes) return null;
    const courierMatch = notes.match(/Courier:\s*(\w+)/i);
    return courierMatch ? courierMatch[1].toUpperCase() : null;
  }

  private extractTrackingFromNotes(notes: string | null): string | undefined {
    if (!notes) return undefined;
    const trackingMatch = notes.match(/Tracking:\s*([A-Z0-9-]+)/i);
    return trackingMatch ? trackingMatch[1] : undefined;
  }

  private mapOrderStatusToDeliveryStatus(orderStatus: string): string {
    const statusMap: Record<string, string> = {
      PENDING: 'PENDING',
      PROCESSING: 'PROCESSING',
      COMPLETED: 'DELIVERED',
      CANCELLED: 'CANCELLED',
    };
    return statusMap[orderStatus] || 'PENDING';
  }
}

export default new DeliveryService();

