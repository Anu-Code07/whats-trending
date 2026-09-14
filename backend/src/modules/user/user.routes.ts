import { Router } from 'express';
import { authMiddleware } from '../../shared/middleware/auth.js';
import type { AuthenticatedRequest } from '../../shared/middleware/auth.js';
import { storiesService } from '../stories/stories.service.js';

export const userRouter = Router();

userRouter.use(authMiddleware);

const AVAILABLE_INTERESTS = [
  'AI', 'Programming', 'Startups', 'Flutter', 'React', 'React Native',
  'iOS', 'Android', 'Web', 'Cloud', 'Cybersecurity', 'Open Source',
  'DevTools', 'Hardware', 'Gaming', 'Robotics', 'Fintech', 'Space',
];

const MOCK_TECH_DNA = [
  { name: 'AI', score: 0.92 },
  { name: 'Developer Tools', score: 0.86 },
  { name: 'Frontend', score: 0.84 },
  { name: 'Flutter', score: 0.73 },
  { name: 'Startups', score: 0.61 },
];

userRouter.get('/', (req, res) => {
  const { userId } = req as AuthenticatedRequest;
  res.json({
    id: userId,
    displayName: 'Developer',
    careerMode: false,
    role: 'Frontend Engineer',
    contentDepth: 'normal',
    notificationFrequency: 'relevant',
    techDna: MOCK_TECH_DNA,
    topCompanies: ['OpenAI', 'Vercel', 'GitHub'],
    topTechnologies: ['React', 'Flutter', 'TypeScript'],
    topTopics: ['AI', 'Frontend', 'Open Source'],
  });
});

userRouter.get('/interests', (_req, res) => {
  res.json({ available: AVAILABLE_INTERESTS, selected: ['AI', 'React', 'Flutter', 'Programming'] });
});

userRouter.put('/interests', (req, res) => {
  const interests = req.body.interests as string[];
  res.json({ selected: interests });
});

userRouter.get('/saved', (req, res) => {
  const { userId } = req as AuthenticatedRequest;
  const stories = storiesService.getSavedStories(userId);
  res.json({ items: stories });
});

userRouter.delete('/personalization', (_req, res) => {
  res.json({ reset: true });
});
