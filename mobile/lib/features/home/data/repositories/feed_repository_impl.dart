import '../../../../core/services/groq_service.dart';
import '../../../../core/storage/user_local_storage.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/news_api_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    NewsApiDatasource? newsDatasource,
    UserLocalStorage? storage,
  })  : _news = newsDatasource ?? NewsApiDatasource(),
        _storage = storage;

  final NewsApiDatasource _news;
  UserLocalStorage? _storage;

  Future<UserLocalStorage> get _user async =>
      _storage ??= await UserLocalStorage.create();

  Future<List<Story>> _loadStories({bool forceRefresh = false}) async {
    final user = await _user;
    final models = await _news.fetchArticles(forceRefresh: forceRefresh);
    final interests = user.interests.map((i) => i.toLowerCase()).toList();
    final savedIds = user.savedStoryIds;

    var stories = models.map((m) {
      var entity = m.toEntity();
      entity = entity.copyWith(isSaved: savedIds.contains(entity.id));

      // Boost relevance for matching interests
      final titleLower = entity.title.toLowerCase();
      final catLower = entity.category.toLowerCase();
      final matches = interests.where(
        (i) => titleLower.contains(i) || catLower.contains(i),
      ).length;

      if (matches > 0) {
        final boosted = (entity.relevanceScore + matches * 0.05).clamp(0.0, 0.99);
        entity = Story(
          id: entity.id,
          slug: entity.slug,
          title: entity.title,
          summary: entity.summary,
          whyItMatters: entity.whyItMatters,
          category: entity.category,
          sourceCount: entity.sourceCount,
          relevanceScore: boosted,
          relevanceExplanation: _explainRelevance(entity, interests),
          impact: entity.impact,
          publishedAt: entity.publishedAt,
          primarySourceName: entity.primarySourceName,
          primarySourceUrl: entity.primarySourceUrl,
          isSaved: entity.isSaved,
          isBreaking: entity.isBreaking,
          whoShouldCare: entity.whoShouldCare,
          sources: entity.sources,
          timeline: entity.timeline,
          communityReaction: entity.communityReaction,
          quickExplanation: entity.quickExplanation,
          deepExplanation: entity.deepExplanation,
          trendScore: entity.trendScore,
        );
      } else {
        entity = entity.copyWith(
          relevanceExplanation: _explainRelevance(entity, interests),
        );
      }

      return entity;
    }).toList();

    stories.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return stories;
  }

  Future<List<Story>> _loadTrendingStories({bool forceRefresh = false}) async {
    final stories = await _loadStories(forceRefresh: forceRefresh);
    final sorted = List<Story>.from(stories);
    sorted.sort((a, b) {
      final trendCmp = b.trendScore.compareTo(a.trendScore);
      if (trendCmp != 0) return trendCmp;
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return sorted;
  }

  String _explainRelevance(Story story, List<String> interests) {
    final titleLower = story.title.toLowerCase();
    final matched = interests.where((i) => titleLower.contains(i)).toList();
    if (matched.isNotEmpty) {
      return 'Related to ${matched.take(2).join(' and ')} you follow.';
    }
    if (story.sourceCount >= 3) {
      return 'Covered by ${story.sourceCount} sources — major story.';
    }
    if (story.isBreaking) return 'Breaking in ${story.category}.';
    return 'Trending in the tech community.';
  }

  String _greeting(String firstName) {
    final hour = DateTime.now().hour;
    final time = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    return 'Good $time, $firstName';
  }

  @override
  Future<FeedData> getFeed({bool forceRefresh = false}) async {
    final user = await _user;
    final stories = await _loadStories(forceRefresh: forceRefresh);

    final lastActive = user.lastActiveAt;
    final sinceLastChecked = lastActive != null
        ? stories.where((s) => s.publishedAt.isAfter(lastActive)).take(5).toList()
        : stories.take(4).toList();

    await user.updateLastActive();

    return FeedData(
      greeting: _greeting(user.firstName),
      sinceLastChecked: sinceLastChecked,
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
    final stories = await _loadStories();
    return (
      topStories: stories.take(5).toList(),
      missedStories: stories.skip(5).take(3).toList(),
    );
  }

  @override
  Future<Story> getStoryById(String id, {String depth = 'normal'}) async {
    final user = await _user;
    await user.markStoryRead(id);

    final models = await _news.fetchArticles();
    final model = models.where((m) => m.id == id || m.slug == id).firstOrNull;
    if (model == null) throw Exception('Story not found');

    var entity = model.toEntity().copyWith(isSaved: user.isStorySaved(id));

    // Enrich with Groq if key is in secure storage
    final groqKey = await user.getGroqApiKey();
    if (groqKey != null && groqKey.isNotEmpty) {
      final groq = GroqService(apiKey: groqKey);
      final whyItMatters = await groq.enrichStory(
        title: entity.title,
        summary: entity.summary,
        source: entity.primarySourceName,
        depth: depth,
      );
      if (whyItMatters != null) {
        entity = entity.copyWith(whyItMatters: whyItMatters);
      }
      if (depth == 'quick') {
        final firstSentence = entity.summary.split('.').first;
        entity = entity.copyWith(summary: '$firstSentence.');
      }
    }

    return entity;
  }

  @override
  Future<void> saveStory(String storyId) async {
    final user = await _user;
    await user.saveStory(storyId);
  }

  @override
  Future<void> unsaveStory(String storyId) async {
    final user = await _user;
    await user.unsaveStory(storyId);
  }

  @override
  Future<List<Story>> getSavedStories() async {
    final user = await _user;
    final stories = await _loadStories();
    return stories.where((s) => user.isStorySaved(s.id)).toList();
  }

  @override
  Future<List<Story>> getTrendingFeed({bool forceRefresh = false}) =>
      _loadTrendingStories(forceRefresh: forceRefresh);

  @override
  Future<List<Story>> getRelatedStories(String storyId, {int limit = 5}) async {
    final stories = await _loadStories();
    final current = stories.where((s) => s.id == storyId).firstOrNull;
    if (current == null) return stories.take(limit).toList();

    final related = stories
        .where((s) => s.id != storyId)
        .map((s) => (
              story: s,
              score: (s.category == current.category ? 3 : 0) +
                  (s.trendScore >= current.trendScore ? 2 : 0) +
                  (s.isHot ? 1 : 0),
            ))
        .where((e) => e.score > 0)
        .toList();

    related.sort((a, b) => b.score.compareTo(a.score));
    return related.take(limit).map((e) => e.story).toList();
  }

  @override
  List<String> getCategories(List<Story> stories) {
    return stories.map((s) => s.category).toSet().toList()..sort();
  }
}
