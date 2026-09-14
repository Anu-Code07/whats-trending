import { Router } from 'express';
import { MOCK_STORIES, toSummary } from '../feed/mock-data.js';

export const discoverRouter = Router();

const TRENDS = [
  { name: 'AI Agents', slug: 'ai-agents', direction: 'rising' as const, volumeChange: 2.4 },
  { name: 'MCP', slug: 'mcp', direction: 'rising' as const, volumeChange: 1.8 },
  { name: 'Local LLMs', slug: 'local-llms', direction: 'rising' as const, volumeChange: 1.2 },
  { name: 'WebGPU', slug: 'webgpu', direction: 'rising' as const, volumeChange: 0.9 },
  { name: 'Flutter', slug: 'flutter', direction: 'stable' as const },
  { name: 'Crypto', slug: 'crypto', direction: 'falling' as const, volumeChange: -0.3 },
];

const COMPANIES = [
  { name: 'OpenAI', slug: 'openai', description: 'AI research and deployment company' },
  { name: 'Google', slug: 'google', description: 'Technology conglomerate' },
  { name: 'Apple', slug: 'apple', description: 'Consumer technology and software' },
  { name: 'Microsoft', slug: 'microsoft', description: 'Cloud, AI, and enterprise software' },
  { name: 'Anthropic', slug: 'anthropic', description: 'AI safety and research' },
  { name: 'NVIDIA', slug: 'nvidia', description: 'GPU and AI computing' },
  { name: 'GitHub', slug: 'github', description: 'Developer platform' },
  { name: 'Vercel', slug: 'vercel', description: 'Frontend cloud platform' },
];

const TECHNOLOGIES = [
  { name: 'React', slug: 'react', description: 'UI library by Meta' },
  { name: 'Flutter', slug: 'flutter', description: 'Cross-platform UI framework' },
  { name: 'TypeScript', slug: 'typescript', description: 'Typed JavaScript superset' },
  { name: 'Rust', slug: 'rust', description: 'Systems programming language' },
  { name: 'Next.js', slug: 'nextjs', description: 'React framework for production' },
  { name: 'Kubernetes', slug: 'kubernetes', description: 'Container orchestration' },
];

discoverRouter.get('/trending', (_req, res) => {
  res.json({ items: MOCK_STORIES.map(toSummary).slice(0, 5) });
});

discoverRouter.get('/rising', (_req, res) => {
  res.json({ items: TRENDS.filter((t) => t.direction === 'rising') });
});

discoverRouter.get('/trends', (_req, res) => {
  res.json({ trends: TRENDS });
});

discoverRouter.get('/companies', (_req, res) => {
  res.json({ items: COMPANIES });
});

discoverRouter.get('/technologies', (_req, res) => {
  res.json({ items: TECHNOLOGIES });
});

discoverRouter.get('/research', (_req, res) => {
  res.json({ items: MOCK_STORIES.filter((s) => s.category === 'AI').map(toSummary) });
});

discoverRouter.get('/startups', (_req, res) => {
  res.json({ items: MOCK_STORIES.filter((s) => s.impact === 'medium').map(toSummary) });
});
