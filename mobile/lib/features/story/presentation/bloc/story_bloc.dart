import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/story.dart';
import '../../../home/domain/usecases/get_story.dart';
import '../../../home/domain/usecases/toggle_save_story.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  StoryBloc({
    required GetStory getStory,
    required ToggleSaveStory toggleSaveStory,
  })  : _getStory = getStory,
        _toggleSaveStory = toggleSaveStory,
        super(const StoryInitial()) {
    on<LoadStory>(_onLoadStory);
    on<ChangeStoryDepth>(_onChangeDepth);
    on<ToggleSave>(_onToggleSave);
  }

  final GetStory _getStory;
  final ToggleSaveStory _toggleSaveStory;

  Future<void> _onLoadStory(LoadStory event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final story = await _getStory(event.storyId, depth: event.depth);
      emit(StoryLoaded(story: story, depth: event.depth));
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }

  Future<void> _onChangeDepth(ChangeStoryDepth event, Emitter<StoryState> emit) async {
    final current = state;
    if (current is! StoryLoaded) return;

    emit(StoryLoading());
    try {
      final story = await _getStory(current.story.id, depth: event.depth);
      emit(StoryLoaded(story: story, depth: event.depth));
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }

  Future<void> _onToggleSave(ToggleSave event, Emitter<StoryState> emit) async {
    final current = state;
    if (current is! StoryLoaded) return;

    await _toggleSaveStory(current.story.id, isSaved: current.story.isSaved);
    emit(StoryLoaded(
      story: current.story.copyWith(isSaved: !current.story.isSaved),
      depth: current.depth,
    ));
  }
}
