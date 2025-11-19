import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { subscriptionGuard } from '../middlewares/subscription-guard';
import customerService from '../services/customer.service';
import { createCustomerSchema, updateCustomerSchema, getCustomersQuerySchema } from '../validators/customer.validator';
import { validate } from '../middlewares/validator';
import { requireTenantId } from '../utils/tenant';

const router = Router();

router.get(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ query: getCustomersQuerySchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const result = await customerService.getCustomers(tenantId, req.query as any);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const customer = await customerService.getCustomerById(req.params.id, tenantId);
      if (!customer) {
        return res.status(404).json({ message: 'Customer not found' });
      }
      res.json(customer);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.post(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ body: createCustomerSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const customer = await customerService.createCustomer(req.body, tenantId);
      res.status(201).json(customer);
    } catch (error: any) {
      console.error('Error creating customer:', error);
      // Handle Prisma/database errors
      if (error.code === 'P1001' || error.code === 'P1002' || error.message?.includes('connect')) {
        res.status(503).json({ 
          error: 'Database connection failed',
          message: 'Unable to connect to database. Please try again.' 
        });
      } else if (error.code?.startsWith('P')) {
        res.status(500).json({ 
          error: 'Database error',
          message: error.message || 'An error occurred while creating customer' 
        });
      } else {
        res.status(500).json({ 
          error: 'Failed to create customer',
          message: error.message || 'An unexpected error occurred' 
        });
      }
    }
  }
);

router.put(
  '/:id',
  authGuard,
  subscriptionGuard,
  validate({ body: updateCustomerSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const customer = await customerService.updateCustomer(req.params.id, req.body, tenantId);
      res.json(customer);
    } catch (error: any) {
      if (error.message === 'Customer not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

router.delete(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      await customerService.deleteCustomer(req.params.id, tenantId);
      res.status(204).send();
    } catch (error: any) {
      if (error.message === 'Customer not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

export default router;

