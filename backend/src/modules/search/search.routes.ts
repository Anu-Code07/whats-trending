import { Router } from 'express';
import { MOCK_STORIES, toSummary } from '../feed/mock-data.js';

export const searchRouter = Router();

searchRouter.get('/', (req, res) => {
  const query = (req.query.q as string ?? '').toLowerCase();
  const type = req.query.type as string ?? 'all';

  if (!query) {
    res.json({ stories: [], companies: [], technologies: [] });
    return;
  }

  const stories = MOCK_STORIES
    .filter(
      (s) =>
        s.title.toLowerCase().includes(query) ||
        s.summary.toLowerCase().includes(query) ||
        s.category.toLowerCase().includes(query),
    )
    .map(toSummary);

  const companies = [
    { name: 'OpenAI', slug: 'openai' },
    { name: 'Google', slug: 'google' },
    { name: 'Apple', slug: 'apple' },
  ].filter((c) => c.name.toLowerCase().includes(query));

  const technologies = [
    { name: 'React', slug: 'react' },
    { name: 'Flutter', slug: 'flutter' },
    { name: 'TypeScript', slug: 'typescript' },
  ].filter((t) => t.name.toLowerCase().includes(query));

  if (type === 'stories') {
    res.json({ stories });
    return;
  }

  res.json({ stories, companies, technologies });
});
