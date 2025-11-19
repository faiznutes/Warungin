import { Router, Request, Response } from 'express';
import { authGuard } from '../middlewares/auth';
import memberService from '../services/member.service';
import { validate } from '../middlewares/validator';
import { z } from 'zod';
import { requireTenantId } from '../utils/tenant';

const router = Router();

const createMemberSchema = z.object({
  name: z.string().min(1),
  email: z.string().email().optional(),
  phone: z.string().min(1),
  address: z.string().optional(),
  discountType: z.enum(['PERCENTAGE', 'FIXED']).optional(),
  discountValue: z.number().optional(),
});

const updateMemberSchema = createMemberSchema.partial().extend({
  isActive: z.boolean().optional(),
});

router.get(
  '/',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const search = req.query.search as string | undefined;
      const isActive = req.query.isActive === 'true' ? true : req.query.isActive === 'false' ? false : undefined;
      const result = await memberService.getMembers(tenantId, page, limit, search, isActive);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/code/:code',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const member = await memberService.getMemberByCode(req.params.code, tenantId);
      if (!member) {
        return res.status(404).json({ message: 'Member not found' });
      }
      res.json(member);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.get(
  '/:id',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const member = await memberService.getMemberById(req.params.id, tenantId);
      if (!member) {
        return res.status(404).json({ message: 'Member not found' });
      }
      res.json(member);
    } catch (error: any) {
      res.status(500).json({ message: error.message });
    }
  }
);

router.post(
  '/',
  authGuard,
  validate({ body: createMemberSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const member = await memberService.createMember(req.body, tenantId);
      res.status(201).json(member);
    } catch (error: any) {
      res.status(400).json({ message: error.message });
    }
  }
);

router.put(
  '/:id',
  authGuard,
  validate({ body: updateMemberSchema }),
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      const member = await memberService.updateMember(req.params.id, req.body, tenantId);
      res.json(member);
    } catch (error: any) {
      if (error.message === 'Member not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

router.delete(
  '/:id',
  authGuard,
  async (req: Request, res: Response) => {
    try {
      const tenantId = requireTenantId(req);
      await memberService.deleteMember(req.params.id, tenantId);
      res.status(204).send();
    } catch (error: any) {
      if (error.message === 'Member not found') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
);

export default router;

