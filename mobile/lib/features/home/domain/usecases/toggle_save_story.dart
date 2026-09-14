import '../repositories/feed_repository.dart';

class ToggleSaveStory {
  const ToggleSaveStory(this._repository);

  final FeedRepository _repository;

  Future<void> call(String storyId, {required bool isSaved}) async {
    if (isSaved) {
      await _repository.unsaveStory(storyId);
    } else {
      await _repository.saveStory(storyId);
    }
  }
}
