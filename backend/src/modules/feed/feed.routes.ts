import { Router } from 'express';
import { authMiddleware } from '../../shared/middleware/auth.js';
import type { AuthenticatedRequest } from '../../shared/middleware/auth.js';
import { feedService } from './feed.service.js';

export const feedRouter = Router();

feedRouter.use(authMiddleware);

feedRouter.get('/', async (req, res, next) => {
  try {
    const { userId } = req as AuthenticatedRequest;
    const feed = await feedService.getFeed(userId);
    res.json(feed);
  } catch (err) {
    next(err);
  }
});

feedRouter.get('/since-last-checked', async (req, res, next) => {
  try {
    const { userId } = req as AuthenticatedRequest;
    const stories = await feedService.getSinceLastChecked(userId);
    res.json({ count: stories.length, stories });
  } catch (err) {
    next(err);
  }
});

feedRouter.get('/brief', async (req, res, next) => {
  try {
    const { userId } = req as AuthenticatedRequest;
    const brief = await feedService.getDailyBrief(userId);
    res.json(brief);
  } catch (err) {
    next(err);
  }
});
