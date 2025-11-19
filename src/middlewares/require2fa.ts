/**
 * Require 2FA Middleware
 * Enforces 2FA for admin roles (ADMIN_TENANT, SUPER_ADMIN)
 */

import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from './auth';
import prisma from '../config/database';
import logger from '../utils/logger';

const ADMIN_ROLES_REQUIRING_2FA = ['ADMIN_TENANT', 'SUPER_ADMIN'];

/**
 * Middleware to require 2FA for admin roles
 * This middleware should be used after authGuard
 */
export const require2FA = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.userId;
    const role = req.role;

    if (!userId || !role) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'User authentication required',
      });
      return;
    }

    // Check if role requires 2FA
    if (!ADMIN_ROLES_REQUIRING_2FA.includes(role)) {
      // Non-admin roles don't require 2FA
      return next();
    }

    // Get user's 2FA status
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        twoFactorEnabled: true,
      } as any, // Type assertion needed until Prisma Client is regenerated
    });

    if (!user) {
      res.status(404).json({
        error: 'User not found',
        message: 'User account not found',
      });
      return;
    }

    const twoFactorEnabled = (user as any).twoFactorEnabled;

    // If 2FA is not enabled, return error
    if (!twoFactorEnabled) {
      logger.warn('2FA required but not enabled', {
        userId,
        role,
        path: req.path,
      });

      res.status(403).json({
        error: '2FA Required',
        message: 'Two-factor authentication is required for admin roles. Please enable 2FA in your account settings.',
        requires2FA: true,
        redirectTo: '/app/settings/2fa',
      });
      return;
    }

    // 2FA is enabled, continue
    next();
  } catch (error: any) {
    logger.error('Error checking 2FA requirement', {
      error: error.message,
      userId: req.userId,
      path: req.path,
    });

    res.status(500).json({
      error: 'Internal server error',
      message: 'An error occurred while checking 2FA requirement',
    });
  }
};

/**
 * Optional 2FA check - doesn't block request but adds flag
 */
export const check2FA = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.userId;
    const role = req.role;

    if (!userId || !role) {
      return next();
    }

    // Check if role requires 2FA
    if (!ADMIN_ROLES_REQUIRING_2FA.includes(role)) {
      return next();
    }

    // Get user's 2FA status
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        twoFactorEnabled: true,
      } as any,
    });

    if (user) {
      // Add 2FA status to request for optional use
      (req as any).twoFactorEnabled = (user as any).twoFactorEnabled;
    }

    next();
  } catch (error: any) {
    // Don't block request on error, just log
    logger.error('Error checking 2FA status', {
      error: error.message,
      userId: req.userId,
    });
    next();
  }
};

