import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { validate } from '../middlewares/validator';
import { z } from 'zod';
import { requireTenantId } from '../utils/tenant';
import analyticsService from '../services/analytics.service';
import { checkBusinessAnalyticsAddon } from '../middlewares/addon-guard';

const router = Router();

const createCustomReportSchema = z.object({
  name: z.string().min(1),
  dataType: z.enum(['SALES', 'PRODUCTS', 'CUSTOMERS', 'INVENTORY']),
  metrics: z.array(z.string()),
  startDate: z.string(),
  endDate: z.string(),
});

router.get(
  '/predictions',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response) => {
    try {
      const userRole = (req as any).user?.role;
      
      // For Super Admin, return platform revenue predictions (subscriptions & addons)
      if (userRole === 'SUPER_ADMIN') {
        const method = (req.query.method as 'moving_average' | 'linear_regression') || 'moving_average';
        const predictions = await analyticsService.getPlatformPredictions(method);
        return res.json(predictions);
      }
      
      const tenantId = requireTenantId(req);
      const method = (req.query.method as 'moving_average' | 'linear_regression') || 'moving_average';
      const predictions = await analyticsService.getPredictions(tenantId, method);
      res.json(predictions);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/top-products',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response) => {
    try {
      const userRole = (req as any).user?.role;
      
      // For Super Admin, return top addons (platform revenue)
      if (userRole === 'SUPER_ADMIN') {
        const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;
        const topAddons = await analyticsService.getTopAddons(limit);
        return res.json(topAddons);
      }
      
      const tenantId = requireTenantId(req);
      const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;
      const products = await analyticsService.getTopProducts(tenantId, limit);
      res.json(products);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/trends',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response) => {
    try {
      const userRole = (req as any).user?.role;
      
      // For Super Admin, return platform revenue trends (subscriptions & addons)
      if (userRole === 'SUPER_ADMIN') {
        const period = (req.query.period as 'daily' | 'weekly' | 'monthly') || 'monthly';
        const trends = await analyticsService.getPlatformTrends(period);
        return res.json(trends);
      }
      
      const tenantId = requireTenantId(req);
      const period = (req.query.period as 'daily' | 'weekly' | 'monthly') || 'monthly';
      const trends = await analyticsService.getTrends(tenantId, period);
      res.json(trends);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/custom-reports',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const reports = await analyticsService.getCustomReports(tenantId);
      res.json({ data: reports });
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.post(
  '/custom-reports',
  authGuard,
  checkBusinessAnalyticsAddon,
  validate({ body: createCustomReportSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const report = await analyticsService.createCustomReport(tenantId, req.body);
      res.status(201).json(report);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

router.get(
  '/custom-reports/:reportId/export',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const report = await analyticsService.exportCustomReport(tenantId, req.params.reportId);
      res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      res.setHeader('Content-Disposition', `attachment; filename=report-${req.params.reportId}.xlsx`);
      res.send(report);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

export default router;

