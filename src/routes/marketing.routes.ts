import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { validate } from '../middlewares/validator';
import { z } from 'zod';
import { requireTenantId } from '../utils/tenant';
import marketingService from '../services/marketing.service';

const router = Router();

const createCampaignSchema = z.object({
  name: z.string().min(1),
  type: z.enum(['SMS', 'EMAIL', 'WHATSAPP', 'PROMO']),
  target: z.enum(['ALL', 'MEMBERS', 'ACTIVE', 'INACTIVE']),
  content: z.string().min(1),
  promoCode: z.string().optional(),
});

const createPromoSchema = z.object({
  name: z.string().min(1),
  type: z.enum(['PERCENTAGE', 'FIXED']),
  value: z.number().positive(),
  code: z.string().min(1),
  startDate: z.string(),
  endDate: z.string(),
});

router.get(
  '/campaigns',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const campaigns = await marketingService.getCampaigns(tenantId);
      res.json({ data: campaigns });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.post(
  '/campaigns',
  authGuard,
  validate({ body: createCampaignSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const campaign = await marketingService.createCampaign(tenantId, req.body);
      res.status(201).json(campaign);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

router.post(
  '/campaigns/:campaignId/send',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const result = await marketingService.sendCampaign(tenantId, req.params.campaignId);
      res.json(result);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

router.post(
  '/promos',
  authGuard,
  validate({ body: createPromoSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const promo = await marketingService.createPromo(tenantId, req.body);
      res.status(201).json(promo);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

export default router;

