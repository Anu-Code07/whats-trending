import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_feed.dart';
import '../../domain/usecases/toggle_save_story.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetFeed getFeed,
    required ToggleSaveStory toggleSaveStory,
  })  : _getFeed = getFeed,
        _toggleSaveStory = toggleSaveStory,
        super(const HomeInitial()) {
    on<LoadHomeFeed>(_onLoadFeed);
    on<RefreshHomeFeed>(_onRefreshFeed);
    on<ToggleStorySave>(_onToggleSave);
  }

  final GetFeed _getFeed;
  final ToggleSaveStory _toggleSaveStory;

  Future<void> _onLoadFeed(LoadHomeFeed event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final feed = await _getFeed();
      emit(HomeLoaded(feed: feed));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshFeed(RefreshHomeFeed event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(feed: current.feed, isRefreshing: true));
    }
    try {
      final feed = await _getFeed();
      emit(HomeLoaded(feed: feed));
    } catch (e) {
      if (current is HomeLoaded) {
        emit(HomeLoaded(feed: current.feed));
      } else {
        emit(HomeError(message: e.toString()));
      }
    }
  }

  Future<void> _onToggleSave(ToggleStorySave event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is! HomeLoaded) return;

    await _toggleSaveStory(event.storyId, isSaved: event.isSaved);

    final updatedStories = current.feed.stories.map((s) {
      if (s.id == event.storyId) return s.copyWith(isSaved: !event.isSaved);
      return s;
    }).toList();

    final updatedSince = current.feed.sinceLastChecked.map((s) {
      if (s.id == event.storyId) return s.copyWith(isSaved: !event.isSaved);
      return s;
    }).toList();

    emit(HomeLoaded(
      feed: FeedData(
        greeting: current.feed.greeting,
        sinceLastChecked: updatedSince,
        stories: updatedStories,
      ),
    ));
  }
}
