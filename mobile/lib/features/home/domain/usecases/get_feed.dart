import '../entities/story.dart';
import '../repositories/feed_repository.dart';

class GetFeed {
  const GetFeed(this._repository);

  final FeedRepository _repository;

  Future<FeedData> call({bool forceRefresh = false}) =>
      _repository.getFeed(forceRefresh: forceRefresh);
}
