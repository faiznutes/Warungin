import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { subscriptionGuard } from '../middlewares/subscription-guard';
import outletService from '../services/outlet.service';
import { validate } from '../middlewares/validator';
import { requireTenantId } from '../utils/tenant';
import { z } from 'zod';

const router = Router();

const createOutletSchema = z.object({
  name: z.string().min(1, 'Nama outlet wajib diisi'),
  address: z.string().optional(),
  phone: z.string().optional(),
});

const updateOutletSchema = z.object({
  name: z.string().min(1).optional(),
  address: z.string().optional(),
  phone: z.string().optional(),
  isActive: z.boolean().optional(),
});

/**
 * GET /api/outlets
 * Get all outlets for current tenant
 */
router.get(
  '/',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const outlets = await outletService.getOutlets(tenantId);
      res.json({ data: outlets });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * GET /api/outlets/:id
 * Get outlet by ID
 */
router.get(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const outlet = await outletService.getOutlet(tenantId, req.params.id);
      res.json({ data: outlet });
    } catch (error: any) {
      res.status(404).json({ message: error.message });
    }
  }
);

/**
 * POST /api/outlets
 * Create new outlet
 */
router.post(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ body: createOutletSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const outlet = await outletService.createOutlet(tenantId, req.body);
      res.status(201).json({ data: outlet });
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * PUT /api/outlets/:id
 * Update outlet
 */
router.put(
  '/:id',
  authGuard,
  subscriptionGuard,
  validate({ body: updateOutletSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const outlet = await outletService.updateOutlet(tenantId, req.params.id, req.body);
      res.json({ data: outlet });
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * DELETE /api/outlets/:id
 * Delete outlet (soft delete if has orders)
 */
router.delete(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      await outletService.deleteOutlet(tenantId, req.params.id);
      res.json({ message: 'Outlet berhasil dihapus' });
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

export default router;

