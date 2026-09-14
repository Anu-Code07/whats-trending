import '../entities/story.dart';

abstract class FeedRepository {
  Future<FeedData> getFeed();
  Future<List<Story>> getSinceLastChecked();
  Future<({List<Story> topStories, List<Story> missedStories})> getDailyBrief();
  Future<Story> getStoryById(String id, {String depth = 'normal'});
  Future<void> saveStory(String storyId);
  Future<void> unsaveStory(String storyId);
  Future<List<Story>> getSavedStories();
}
