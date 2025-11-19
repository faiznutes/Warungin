import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { requireTenantId } from '../utils/tenant';
import financeService from '../services/finance.service';
import { checkBusinessAnalyticsAddon } from '../middlewares/addon-guard';

const router = Router();

router.get(
  '/summary',
  authGuard,
  async (req: Request, res: Response, next) => {
    try {
      const tenantId = requireTenantId(req);
      const startDate = req.query.startDate as string;
      const endDate = req.query.endDate as string;
      const summary = await financeService.getFinancialSummary(tenantId, startDate, endDate);
      res.json(summary);
    } catch (error: any) {
      next(error);
    }
  }
);

router.get(
  '/profit-loss',
  authGuard,
  checkBusinessAnalyticsAddon,
  async (req: Request, res: Response, next) => {
    try {
      const userRole = (req as any).user?.role;
      
      // For Super Admin, return platform revenue profit-loss (subscriptions & addons)
      if (userRole === 'SUPER_ADMIN') {
        const startDate = req.query.startDate as string;
        const endDate = req.query.endDate as string;
        const shouldExport = req.query.export === 'true';
        const profitLoss = await financeService.getPlatformProfitLoss(startDate, endDate);
        
        // If export requested, generate PDF
        if (shouldExport) {
          const { generatePDF } = await import('../services/pdf.service');
          const pdfBuffer = await generatePDF('profit-loss', {
            profitLoss,
            startDate,
            endDate,
            tenantId: 'platform',
            tenantName: 'Platform Revenue',
          });
          
          res.setHeader('Content-Type', 'application/pdf');
          res.setHeader('Content-Disposition', `attachment; filename=laporan-laba-rugi-platform-${startDate || 'all'}-${endDate || 'all'}.pdf`);
          res.send(pdfBuffer);
          return;
        }
        
        return res.json(profitLoss);
      }
      
      const tenantId = requireTenantId(req);
      const startDate = req.query.startDate as string;
      const endDate = req.query.endDate as string;
      const shouldExport = req.query.export === 'true';
      
      const profitLoss = await financeService.getProfitLoss(tenantId, startDate, endDate);
      
      // If export requested, generate PDF
      if (shouldExport) {
        const { generatePDF } = await import('../services/pdf.service');
        const prisma = (await import('../config/database')).default;
        
        // Get tenant name for PDF
        const tenant = await prisma.tenant.findUnique({
          where: { id: tenantId },
          select: { name: true },
        });
        
        const pdfBuffer = await generatePDF('profit-loss', {
          profitLoss,
          startDate,
          endDate,
          tenantId,
          tenantName: tenant?.name || 'Tenant',
        });
        
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=laporan-laba-rugi-${startDate || 'all'}-${endDate || 'all'}.pdf`);
        res.send(pdfBuffer);
        return;
      }
      
      res.json(profitLoss);
    } catch (error: any) {
      next(error);
    }
  }
);

router.get(
  '/balance-sheet',
  authGuard,
  async (req: Request, res: Response, next) => {
    try {
      const tenantId = requireTenantId(req);
      const startDate = req.query.startDate as string;
      const endDate = req.query.endDate as string;
      const balanceSheet = await financeService.getBalanceSheet(tenantId, startDate, endDate);
      res.json(balanceSheet);
    } catch (error: any) {
      next(error);
    }
  }
);

router.get(
  '/cash-flow',
  authGuard,
  async (req: Request, res: Response, next) => {
    try {
      const tenantId = requireTenantId(req);
      const startDate = req.query.startDate as string;
      const endDate = req.query.endDate as string;
      const cashFlow = await financeService.getCashFlow(tenantId, startDate, endDate);
      res.json(cashFlow);
    } catch (error: any) {
      next(error);
    }
  }
);

export default router;

