import { Router } from 'express';
import { z } from 'zod';
import { authMiddleware } from '../../shared/middleware/auth.js';
import type { AuthenticatedRequest } from '../../shared/middleware/auth.js';
import { storiesService } from './stories.service.js';

export const storiesRouter = Router();

storiesRouter.use(authMiddleware);

storiesRouter.get('/:id', (req, res, next) => {
  try {
    const depth = (req.query.depth as 'quick' | 'normal' | 'deep') ?? 'normal';
    const story = storiesService.getById(req.params.id, depth);
    res.json(story);
  } catch (err) {
    next(err);
  }
});

storiesRouter.post('/:id/save', (req, res, next) => {
  try {
    const { userId } = req as unknown as AuthenticatedRequest;
    const body = z.object({ collection: z.enum(['read_later', 'learn', 'career', 'build_ideas', 'interesting']).optional() }).parse(req.body);
    storiesService.saveStory(userId, req.params.id, body.collection ?? 'read_later');
    res.json({ saved: true });
  } catch (err) {
    next(err);
  }
});

storiesRouter.delete('/:id/save', (req, res, next) => {
  try {
    const { userId } = req as unknown as AuthenticatedRequest;
    storiesService.unsaveStory(userId, req.params.id);
    res.json({ saved: false });
  } catch (err) {
    next(err);
  }
});

storiesRouter.post('/:id/build-ideas', (req, res, next) => {
  try {
    const ideas = storiesService.generateBuildIdeas(req.params.id);
    res.json({
      disclaimer: 'These are AI-generated project ideas, not factual information.',
      ideas,
    });
  } catch (err) {
    next(err);
  }
});

storiesRouter.post('/:id/interactions', (req, res, next) => {
  try {
    const body = z.object({
      type: z.enum(['opened', 'completed', 'saved', 'shared', 'ignored']),
      durationMs: z.number().optional(),
    }).parse(req.body);
    res.json({ recorded: true, type: body.type });
  } catch (err) {
    next(err);
  }
});
