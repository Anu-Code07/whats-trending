import type { NextFunction, Request, Response } from 'express';

const MOCK_USER_ID = 'user-demo-001';

export interface AuthenticatedRequest extends Request {
  userId: string;
}

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const userId = (req.headers['x-user-id'] as string) ?? MOCK_USER_ID;
  (req as AuthenticatedRequest).userId = userId;
  next();
}
