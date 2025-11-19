import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { subscriptionGuard } from '../middlewares/subscription-guard';
import orderService from '../services/order.service';
import { createOrderSchema, updateOrderStatusSchema, getOrdersQuerySchema, updateOrderSchema } from '../validators/order.validator';
import { validate } from '../middlewares/validator';
import { requireTenantId } from '../utils/tenant';
import { z } from 'zod';

const router = Router();

/**
 * @swagger
 * /api/orders:
 *   get:
 *     summary: Get all orders
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ query: getOrdersQuerySchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userRole = (req as any).user.role;
      const result = await orderService.getOrders(tenantId, req.query as any, userRole);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/bulk-update-kitchen:
 *   put:
 *     summary: Bulk update kitchen status for multiple orders
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/bulk-update-kitchen',
  authGuard,
  subscriptionGuard,
  validate({ body: z.object({ 
    orderIds: z.array(z.string()).min(1),
    status: z.enum(['PENDING', 'COOKING', 'READY', 'SERVED'])
  }) }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const { orderIds, status } = req.body;
      
      const results = await orderService.bulkUpdateKitchenStatus(tenantId, orderIds, status);
      res.json(results);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/stats:
 *   get:
 *     summary: Get order statistics
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/stats/summary',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const { startDate, endDate } = req.query;
      const stats = await orderService.getOrderStats(
        tenantId,
        startDate ? new Date(startDate as string) : undefined,
        endDate ? new Date(endDate as string) : undefined
      );
      res.json(stats);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/{id}:
 *   get:
 *     summary: Get order by ID
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/:id',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const order = await orderService.getOrderById(req.params.id, tenantId);
      if (!order) {
        return res.status(404).json({ message: 'Order not found' });
      }
      res.json(order);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders:
 *   post:
 *     summary: Create new order
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ body: createOrderSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userId = (req as any).user.id;
      const order = await orderService.createOrder(req.body, userId, tenantId);
      res.status(201).json(order);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/{id}:
 *   put:
 *     summary: Update order
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/:id',
  authGuard,
  validate({ body: updateOrderSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const order = await orderService.getOrderById(req.params.id, tenantId);
      if (!order) {
        return res.status(404).json({ message: 'Order not found' });
      }

      // Pass all validated data to updateOrder service
      const updatedOrder = await orderService.updateOrder(req.params.id, req.body, tenantId);
      res.json(updatedOrder);
    } catch (error: any) {
      if (error.message === 'Order not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/{id}/status:
 *   put:
 *     summary: Update order status
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/:id/status',
  authGuard,
  validate({ body: updateOrderStatusSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const order = await orderService.updateOrderStatus(req.params.id, req.body, tenantId);
      res.json(order);
    } catch (error: any) {
      if (error.message === 'Order not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/{id}/kitchen-status:
 *   put:
 *     summary: Update kitchen status for an order
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/:id/kitchen-status',
  authGuard,
  subscriptionGuard,
  validate({ body: z.object({ status: z.enum(['PENDING', 'COOKING', 'READY', 'SERVED']) }) }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const order = await orderService.getOrderById(req.params.id, tenantId);
      if (!order) {
        return res.status(404).json({ message: 'Order not found' });
      }

      // Only update if order is sent to kitchen
      if (!order.sendToKitchen) {
        return res.status(400).json({ message: 'Order is not sent to kitchen' });
      }

      const updatedOrder = await orderService.updateOrder(req.params.id, {
        kitchenStatus: req.body.status,
      }, tenantId);
      res.json(updatedOrder);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/bulk-delete:
 *   post:
 *     summary: Bulk delete orders
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/bulk-delete',
  authGuard,
  subscriptionGuard,
  validate({ body: z.object({ orderIds: z.array(z.string()).min(1) }) }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userRole = (req as any).user.role;
      
      // Only ADMIN_TENANT and SUPER_ADMIN can delete orders
      if (userRole !== 'ADMIN_TENANT' && userRole !== 'SUPER_ADMIN') {
        return res.status(403).json({ message: 'Only admin can delete orders' });
      }

      const { orderIds } = req.body;
      const result = await orderService.bulkDeleteOrders(tenantId, orderIds);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/bulk-refund:
 *   post:
 *     summary: Bulk refund orders
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/bulk-refund',
  authGuard,
  subscriptionGuard,
  validate({ body: z.object({ orderIds: z.array(z.string()).min(1) }) }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userRole = (req as any).user.role;
      
      // Only ADMIN_TENANT and SUPER_ADMIN can refund orders
      if (userRole !== 'ADMIN_TENANT' && userRole !== 'SUPER_ADMIN') {
        return res.status(403).json({ message: 'Only admin can refund orders' });
      }

      const { orderIds } = req.body;
      const result = await orderService.bulkRefundOrders(tenantId, orderIds);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/orders/{id}:
 *   delete:
 *     summary: Delete single order
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 */
router.delete(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userRole = (req as any).user.role;
      
      // Only ADMIN_TENANT and SUPER_ADMIN can delete orders
      if (userRole !== 'ADMIN_TENANT' && userRole !== 'SUPER_ADMIN') {
        return res.status(403).json({ message: 'Only admin can delete orders' });
      }

      await orderService.deleteOrder(req.params.id, tenantId);
      res.status(204).send();
    } catch (error: any) {
      if (error.message === 'Order not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

export default router;
