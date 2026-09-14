import '../storage/user_local_storage.dart';
import '../../features/home/data/repositories/feed_repository_impl.dart';
import '../../features/home/domain/repositories/feed_repository.dart';
import '../../features/home/domain/usecases/get_feed.dart';
import '../../features/home/domain/usecases/get_story.dart';
import '../../features/home/domain/usecases/toggle_save_story.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/story/presentation/bloc/story_bloc.dart';

class ServiceLocator {
  static UserLocalStorage? _storage;
  static FeedRepository? _feedRepository;

  static Future<void> init() async {
    _storage = await UserLocalStorage.create();
    _feedRepository = FeedRepositoryImpl(storage: _storage);
  }

  static UserLocalStorage get storage {
    if (_storage == null) throw StateError('ServiceLocator not initialized');
    return _storage!;
  }

  static FeedRepository get feedRepository {
    if (_feedRepository == null) throw StateError('ServiceLocator not initialized');
    return _feedRepository!;
  }

  static HomeBloc createHomeBloc() => HomeBloc(
        getFeed: GetFeed(feedRepository),
        toggleSaveStory: ToggleSaveStory(feedRepository),
      );

  static StoryBloc createStoryBloc(String storyId) => StoryBloc(
        getStory: GetStory(feedRepository),
        toggleSaveStory: ToggleSaveStory(feedRepository),
      )..add(LoadStory(storyId: storyId));
}
