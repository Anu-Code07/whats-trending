import '../../features/home/data/repositories/feed_repository_impl.dart';
import '../../features/home/domain/repositories/feed_repository.dart';
import '../../features/home/domain/usecases/get_feed.dart';
import '../../features/home/domain/usecases/get_story.dart';
import '../../features/home/domain/usecases/toggle_save_story.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/story/presentation/bloc/story_bloc.dart';

class ServiceLocator {
  static final FeedRepository _feedRepository = FeedRepositoryImpl();

  static FeedRepository get feedRepository => _feedRepository;

  static HomeBloc createHomeBloc() => HomeBloc(
        getFeed: GetFeed(_feedRepository),
        toggleSaveStory: ToggleSaveStory(_feedRepository),
      );

  static StoryBloc createStoryBloc(String storyId) => StoryBloc(
        getStory: GetStory(_feedRepository),
        toggleSaveStory: ToggleSaveStory(_feedRepository),
      )..add(LoadStory(storyId: storyId));
}
