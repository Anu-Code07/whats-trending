part of 'story_bloc.dart';

sealed class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadStory extends StoryEvent {
  const LoadStory({required this.storyId, this.depth = 'normal'});

  final String storyId;
  final String depth;

  @override
  List<Object?> get props => [storyId, depth];
}

final class ChangeStoryDepth extends StoryEvent {
  const ChangeStoryDepth({required this.depth});

  final String depth;

  @override
  List<Object?> get props => [depth];
}

final class ToggleSave extends StoryEvent {
  const ToggleSave();
}
