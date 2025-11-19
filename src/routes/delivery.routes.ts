import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { validate } from '../middlewares/validator';
import { z } from 'zod';
import { requireTenantId } from '../utils/tenant';
import deliveryService from '../services/delivery.service';

const router = Router();

const createCourierSchema = z.object({
  courier: z.string().min(1),
  apiKey: z.string().min(1),
});

const processDeliverySchema = z.object({
  trackingNumber: z.string().optional(),
  courier: z.string().optional(),
});

router.get(
  '/orders',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const orders = await deliveryService.getDeliveryOrders(tenantId);
      res.json({ data: orders });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.post(
  '/orders/:orderId/process',
  authGuard,
  validate({ body: processDeliverySchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const order = await deliveryService.processDelivery(tenantId, req.params.orderId, req.body);
      res.json(order);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

router.post(
  '/couriers',
  authGuard,
  validate({ body: createCourierSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const courier = await deliveryService.setupCourier(tenantId, req.body);
      res.status(201).json(courier);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

export default router;

