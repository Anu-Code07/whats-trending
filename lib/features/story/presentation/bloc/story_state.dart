part of 'story_bloc.dart';

sealed class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

final class StoryInitial extends StoryState {
  const StoryInitial();
}

final class StoryLoading extends StoryState {
  const StoryLoading();
}

final class StoryLoaded extends StoryState {
  const StoryLoaded({required this.story, required this.depth});

  final Story story;
  final String depth;

  @override
  List<Object?> get props => [story, depth];
}

final class StoryError extends StoryState {
  const StoryError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
