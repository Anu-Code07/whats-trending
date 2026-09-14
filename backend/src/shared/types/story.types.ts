export type ImpactLevel = 'low' | 'medium' | 'high' | 'critical';
export type ContentDepth = 'quick' | 'normal' | 'deep';
export type SaveCollection = 'read_later' | 'learn' | 'career' | 'build_ideas' | 'interesting';

export interface StorySource {
  name: string;
  url: string;
  contentType: 'official' | 'journalism' | 'community' | 'analysis';
}

export interface StoryTimelineItem {
  id: string;
  type: 'breaking' | 'updated' | 'reaction' | 'analysis';
  title: string;
  occurredAt: string;
}

export interface CommunityReaction {
  themes: string[];
  summary: string;
  source: string;
}

export interface StorySummary {
  id: string;
  slug: string;
  title: string;
  summary: string;
  whyItMatters: string;
  category: string;
  sourceCount: number;
  relevanceScore: number;
  relevanceExplanation: string;
  impact: ImpactLevel;
  publishedAt: string;
  primarySource: { name: string; url: string };
  isSaved: boolean;
  isBreaking?: boolean;
}

export interface StoryDetail extends StorySummary {
  whoShouldCare: string[];
  sources: StorySource[];
  timeline: StoryTimelineItem[];
  communityReaction?: CommunityReaction;
  deepExplanation?: string;
  quickExplanation?: string;
}

export interface FeedResponse {
  greeting: string;
  sinceLastChecked: {
    count: number;
    stories: StorySummary[];
  };
  items: StorySummary[];
  nextCursor: string | null;
}

export interface DailyBriefResponse {
  date: string;
  topStories: StorySummary[];
  missedStories: StorySummary[];
}
