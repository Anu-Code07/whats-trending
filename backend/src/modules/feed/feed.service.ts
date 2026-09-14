import { DeterministicRankingStrategy } from '../ranking/ranking.strategy.js';
import { MOCK_STORIES, toSummary } from './mock-data.js';
import type { DailyBriefResponse, FeedResponse, StorySummary } from '../../shared/types/story.types.js';

const rankingStrategy = new DeterministicRankingStrategy();

const DEFAULT_INTERESTS = ['react', 'ai', 'flutter', 'programming', 'open source', 'cybersecurity'];

function getGreeting(now: Date): string {
  const hour = now.getHours();
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

export class FeedService {
  async getFeed(userId: string, interests: string[] = DEFAULT_INTERESTS): Promise<FeedResponse> {
    const now = new Date();
    const summaries = MOCK_STORIES.map(toSummary);
    const ranked = await rankingStrategy.rank(summaries, {
      userId,
      userInterestSlugs: interests,
      recentCategoryReads: ['Programming', 'AI'],
      now,
    });

    const sinceStories = ranked.slice(0, 4);

    return {
      greeting: getGreeting(now),
      sinceLastChecked: {
        count: sinceStories.length,
        stories: sinceStories,
      },
      items: ranked,
      nextCursor: null,
    };
  }

  async getSinceLastChecked(userId: string, interests: string[] = DEFAULT_INTERESTS): Promise<StorySummary[]> {
    const feed = await this.getFeed(userId, interests);
    return feed.sinceLastChecked.stories;
  }

  async getDailyBrief(userId: string, interests: string[] = DEFAULT_INTERESTS): Promise<DailyBriefResponse> {
    const feed = await this.getFeed(userId, interests);
    const topStories = feed.items.slice(0, 5);
    const missedStories = feed.items.slice(5, 8);

    return {
      date: new Date().toISOString().split('T')[0],
      topStories,
      missedStories,
    };
  }
}

export const feedService = new FeedService();
