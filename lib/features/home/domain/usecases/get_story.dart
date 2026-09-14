import '../entities/story.dart';
import '../repositories/feed_repository.dart';

class GetStory {
  const GetStory(this._repository);

  final FeedRepository _repository;

  Future<Story> call(String id, {String depth = 'normal'}) =>
      _repository.getStoryById(id, depth: depth);
}
