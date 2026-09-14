import '../../domain/entities/story.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/mock_feed_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({MockFeedDatasource? datasource})
      : _datasource = datasource ?? MockFeedDatasource();

  final MockFeedDatasource _datasource;
  final Set<String> _savedStoryIds = {};

  List<Story> _getAllEntities() {
    return _datasource.getAllStories().map((m) {
      final entity = m.toEntity();
      return entity.copyWith(isSaved: _savedStoryIds.contains(entity.id));
    }).toList();
  }

  @override
  Future<FeedData> getFeed() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final stories = _getAllEntities();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return FeedData(
      greeting: greeting,
      sinceLastChecked: stories.take(4).toList(),
      stories: stories,
    );
  }

  @override
  Future<List<Story>> getSinceLastChecked() async {
    final feed = await getFeed();
    return feed.sinceLastChecked;
  }

  @override
  Future<({List<Story> topStories, List<Story> missedStories})> getDailyBrief() async {
    final stories = _getAllEntities();
    return (
      topStories: stories.take(5).toList(),
      missedStories: stories.skip(5).take(3).toList(),
    );
  }

  @override
  Future<Story> getStoryById(String id, {String depth = 'normal'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final model = _datasource.getStoryById(id);
    if (model == null) throw Exception('Story not found');

    var entity = model.toEntity().copyWith(isSaved: _savedStoryIds.contains(id));

    if (depth == 'quick' && entity.quickExplanation != null) {
      entity = entity.copyWith(summary: entity.quickExplanation);
    } else if (depth == 'deep' && entity.deepExplanation != null) {
      entity = entity.copyWith(summary: entity.deepExplanation);
    }

    return entity;
  }

  @override
  Future<void> saveStory(String storyId) async {
    _savedStoryIds.add(storyId);
  }

  @override
  Future<void> unsaveStory(String storyId) async {
    _savedStoryIds.remove(storyId);
  }

  @override
  Future<List<Story>> getSavedStories() async {
    return _getAllEntities().where((s) => _savedStoryIds.contains(s.id)).toList();
  }
}
