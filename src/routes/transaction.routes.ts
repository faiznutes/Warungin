import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { subscriptionGuard } from '../middlewares/subscription-guard';
import transactionService from '../services/transaction.service';
import { requireTenantId } from '../utils/tenant';
import { z } from 'zod';
import { validate } from '../middlewares/validator';

const router = Router();

const createTransactionSchema = z.object({
  orderId: z.string(),
  amount: z.number().positive(),
  paymentMethod: z.enum(['CASH', 'QRIS', 'BANK_TRANSFER', 'SHOPEEPAY', 'DANA', 'CARD', 'E_WALLET']),
  status: z.enum(['PENDING', 'COMPLETED', 'FAILED', 'REFUNDED']).optional(),
  reference: z.string().optional(),
  qrCode: z.string().optional(), // QR Code string untuk QRIS manual
  qrCodeImage: z.string().url().optional(), // URL gambar QR Code (opsional)
  notes: z.string().optional(),
  servedBy: z.string().optional(), // Nama kasir/admin yang melayani
});

/**
 * @swagger
 * /api/transactions:
 *   post:
 *     summary: Create transaction
 *     tags: [Transactions]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ body: createTransactionSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userId = (req as any).user.id;
      
      const transaction = await transactionService.createTransaction(
        req.body,
        userId,
        tenantId
      );
      
      res.status(201).json(transaction);
    } catch (error: any) {
      console.error('Transaction creation error:', error);
      res.status(400).json({ message: error.message || 'Failed to create transaction' });
    }
  }
);

/**
 * @swagger
 * /api/transactions:
 *   get:
 *     summary: Get transactions
 *     tags: [Transactions]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      
      const result = await transactionService.getTransactions(tenantId, page, limit);
      res.json(result);
    } catch (error: any) {
      console.error('Error fetching transactions:', error);
      res.status(500).json({ message: error.message || 'Failed to fetch transactions' });
    }
  }
);

/**
 * @swagger
 * /api/transactions/{id}:
 *   get:
 *     summary: Get transaction by ID
 *     tags: [Transactions]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/:id',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const transaction = await transactionService.getTransactionById(req.params.id, tenantId);
      
      if (!transaction) {
        return res.status(404).json({ message: 'Transaction not found' });
      }
      
      res.json(transaction);
    } catch (error: any) {
      console.error('Error fetching transaction:', error);
      res.status(500).json({ message: error.message || 'Failed to fetch transaction' });
    }
  }
);

export default router;

