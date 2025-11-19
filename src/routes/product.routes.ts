import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import { subscriptionGuard } from '../middlewares/subscription-guard';
import productService from '../services/product.service';
import productAdjustmentService, { createProductAdjustmentSchema } from '../services/product-adjustment.service';
import { createProductSchema, updateProductSchema, getProductsQuerySchema } from '../validators/product.validator';
import { validate } from '../middlewares/validator';
import { requireTenantId } from '../utils/tenant';
import { AuthRequest } from '../middlewares/auth';
import { logAction } from '../middlewares/audit-logger';
import { validateImageUpload } from '../middlewares/file-upload-validator';

const router = Router();

/**
 * @swagger
 * /api/products:
 *   get:
 *     summary: Get all products
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of products
 */
router.get(
  '/',
  authGuard,
  subscriptionGuard,
  validate({ query: getProductsQuerySchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const result = await productService.getProducts(tenantId, req.query as any);
      res.json(result);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/{id}:
 *   get:
 *     summary: Get product by ID
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/:id',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const product = await productService.getProductById(req.params.id, tenantId);
      if (!product) {
        return res.status(404).json({ message: 'Product not found' });
      }
      res.json(product);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products:
 *   post:
 *     summary: Create new product
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/',
  authGuard,
  subscriptionGuard,
  validateImageUpload, // Validate image upload security
  validate({ body: createProductSchema }),
  async (req: AuthRequest, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const product = await productService.createProduct(req.body, tenantId);
      
      // Log audit
      await logAction(req, 'CREATE', 'products', product.id, { name: product.name, price: product.price }, 'SUCCESS');
      
      res.status(201).json(product);
    } catch (error: any) {
      await logAction(req, 'CREATE', 'products', null, { error: error.message }, 'FAILED', error.message);
      res.status(400).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/{id}:
 *   put:
 *     summary: Update product
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/:id',
  authGuard,
  validateImageUpload, // Validate image upload security
  validate({ body: updateProductSchema }),
  async (req: AuthRequest, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const product = await productService.updateProduct(req.params.id, req.body, tenantId);
      
      // Log audit
      await logAction(req, 'UPDATE', 'products', product.id, { changes: req.body }, 'SUCCESS');
      
      res.json(product);
    } catch (error: any) {
      await logAction(req, 'UPDATE', 'products', req.params.id, { error: error.message }, 'FAILED', error.message);
      if (error.message === 'Product not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/{id}:
 *   delete:
 *     summary: Delete product
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.delete(
  '/:id',
  authGuard,
  async (req: AuthRequest, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const product = await productService.getProductById(req.params.id, tenantId);
      await productService.deleteProduct(req.params.id, tenantId);
      
      // Log audit
      if (product) {
        await logAction(req, 'DELETE', 'products', req.params.id, { name: product.name }, 'SUCCESS');
      }
      
      res.status(204).send();
    } catch (error: any) {
      await logAction(req, 'DELETE', 'products', req.params.id, { error: error.message }, 'FAILED', error.message);
      if (error.message === 'Product not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/{id}/stock:
 *   put:
 *     summary: Update product stock
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/:id/stock',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const { quantity, operation } = req.body;
      const product = await productService.updateStock(
        req.params.id,
        quantity,
        tenantId,
        operation || 'set'
      );
      res.json(product);
    } catch (error: any) {
      if (error.message === 'Product not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/low-stock:
 *   get:
 *     summary: Get low stock products
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/low-stock/all',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const products = await productService.getLowStockProducts(tenantId);
      res.json(products);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/adjustments:
 *   get:
 *     summary: Get all product adjustments
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/adjustments',
  authGuard,
  subscriptionGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const query = {
        page: req.query.page ? parseInt(req.query.page as string) : 1,
        limit: req.query.limit ? parseInt(req.query.limit as string) : 50,
        productId: req.query.productId as string | undefined,
      };
      const result = await productAdjustmentService.getAdjustments(tenantId, query);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/adjustments:
 *   post:
 *     summary: Create product adjustment
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/adjustments',
  authGuard,
  subscriptionGuard,
  validate({ body: createProductAdjustmentSchema }),
  async (req: AuthRequest, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const userId = req.userId!;
      const adjustment = await productAdjustmentService.createAdjustment(
        req.body,
        tenantId,
        userId
      );
      
      // Log audit
      await logAction(
        req,
        'CREATE',
        'product_adjustments',
        adjustment.id,
        {
          productId: adjustment.productId,
          type: adjustment.type,
          quantity: adjustment.quantity,
          reason: adjustment.reason,
        },
        'SUCCESS'
      );
      
      res.status(201).json(adjustment);
    } catch (error: any) {
      await logAction(req, 'CREATE', 'product_adjustments', null, { error: error.message }, 'FAILED', error.message);
      if (error.message === 'Product not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

/**
 * @swagger
 * /api/products/adjustments/{id}:
 *   get:
 *     summary: Get product adjustment by ID
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/adjustments/:id',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const adjustment = await productAdjustmentService.getAdjustmentById(
        req.params.id,
        tenantId
      );
      if (!adjustment) {
        return res.status(404).json({ message: 'Adjustment not found' });
      }
      res.json(adjustment);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

export default router;

