import type { StorySummary } from '../../shared/types/story.types.js';

export interface RankingContext {
  userId: string;
  userInterestSlugs: string[];
  recentCategoryReads: string[];
  now: Date;
}

export interface RankingStrategy {
  rank(stories: StorySummary[], context: RankingContext): Promise<StorySummary[]>;
}

const WEIGHTS = {
  topicMatch: 0.30,
  freshness: 0.15,
  importance: 0.20,
  sourceQuality: 0.10,
  developerImpact: 0.15,
  novelty: 0.10,
};

function freshnessScore(publishedAt: string, now: Date): number {
  const hours = (now.getTime() - new Date(publishedAt).getTime()) / 3_600_000;
  return Math.exp(-0.02 * hours);
}

function topicMatchScore(story: StorySummary, interests: string[]): number {
  const category = story.category.toLowerCase();
  const matches = interests.filter(
    (i) => category.includes(i) || story.title.toLowerCase().includes(i),
  );
  return Math.min(1, matches.length * 0.35 + 0.3);
}

function noveltyScore(story: StorySummary, recentCategories: string[]): number {
  const count = recentCategories.filter((c) => c === story.category).length;
  return Math.max(0.2, 1 - count * 0.25);
}

function developerImpactScore(story: StorySummary): number {
  const devKeywords = ['api', 'release', 'framework', 'open-source', 'developer', 'sdk'];
  const text = `${story.title} ${story.summary}`.toLowerCase();
  const hits = devKeywords.filter((k) => text.includes(k)).length;
  return Math.min(1, 0.3 + hits * 0.15);
}

function buildExplanation(story: StorySummary, interests: string[]): string {
  const matched = interests.filter(
    (i) =>
      story.category.toLowerCase().includes(i) ||
      story.title.toLowerCase().includes(i),
  );

  if (matched.length > 0) {
    const topics = matched.slice(0, 3).join(', ');
    return `You frequently read ${topics} stories.`;
  }

  if (story.sourceCount >= 20) {
    return `Major development with ${story.sourceCount} sources reporting.`;
  }

  if (story.isBreaking) {
    return 'Breaking story in your areas of interest.';
  }

  return 'Trending in the technology community.';
}

export class DeterministicRankingStrategy implements RankingStrategy {
  async rank(stories: StorySummary[], context: RankingContext): Promise<StorySummary[]> {
    const scored = stories.map((story) => {
      const topic = topicMatchScore(story, context.userInterestSlugs);
      const fresh = freshnessScore(story.publishedAt, context.now);
      const importance = story.sourceCount >= 30 ? 0.95 : story.sourceCount / 40;
      const sourceQuality = story.primarySource.name.includes('Official') ? 0.9 : 0.6;
      const devImpact = developerImpactScore(story);
      const novelty = noveltyScore(story, context.recentCategoryReads);

      const relevance =
        WEIGHTS.topicMatch * topic +
        WEIGHTS.freshness * fresh +
        WEIGHTS.importance * importance +
        WEIGHTS.sourceQuality * sourceQuality +
        WEIGHTS.developerImpact * devImpact +
        WEIGHTS.novelty * novelty;

      return {
        ...story,
        relevanceScore: Math.round(relevance * 100) / 100,
        relevanceExplanation: buildExplanation(story, context.userInterestSlugs),
      };
    });

    return scored.sort((a, b) => b.relevanceScore - a.relevanceScore);
  }
}
