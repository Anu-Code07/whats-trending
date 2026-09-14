import { AppError } from '../../shared/middleware/error-handler.js';
import { MOCK_STORIES } from '../feed/mock-data.js';
import type { ContentDepth, SaveCollection, StoryDetail } from '../../shared/types/story.types.js';

const savedStories = new Map<string, Set<string>>();

export class StoriesService {
  getById(id: string, depth: ContentDepth = 'normal'): StoryDetail {
    const story = MOCK_STORIES.find((s) => s.id === id);
    if (!story) {
      throw new AppError(404, 'Story not found');
    }

    if (depth === 'quick' && story.quickExplanation) {
      return { ...story, summary: story.quickExplanation };
    }

    if (depth === 'deep' && story.deepExplanation) {
      return { ...story, summary: story.deepExplanation };
    }

    return story;
  }

  saveStory(userId: string, storyId: string, collection: SaveCollection): void {
    if (!savedStories.has(userId)) {
      savedStories.set(userId, new Set());
    }
    savedStories.get(userId)!.add(storyId);
  }

  unsaveStory(userId: string, storyId: string): void {
    savedStories.get(userId)?.delete(storyId);
  }

  isSaved(userId: string, storyId: string): boolean {
    return savedStories.get(userId)?.has(storyId) ?? false;
  }

  getSavedStories(userId: string): StoryDetail[] {
    const ids = savedStories.get(userId) ?? new Set();
    return MOCK_STORIES.filter((s) => ids.has(s.id));
  }

  generateBuildIdeas(storyId: string): { level: string; idea: string }[] {
    const story = MOCK_STORIES.find((s) => s.id === storyId);
    if (!story) {
      throw new AppError(404, 'Story not found');
    }

    return [
      {
        level: 'beginner',
        idea: `Build a simple demo app showcasing the key feature from "${story.title}".`,
      },
      {
        level: 'intermediate',
        idea: `Create a comparison tool that evaluates the technology discussed in this story against alternatives.`,
      },
      {
        level: 'advanced',
        idea: `Design a production-ready integration using the APIs or tools mentioned, with monitoring and fallbacks.`,
      },
      {
        level: 'startup',
        idea: `Identify a niche workflow this technology enables and build a focused SaaS tool around it.`,
      },
    ];
  }
}

export const storiesService = new StoriesService();
