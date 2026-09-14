part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHomeFeed extends HomeEvent {
  const LoadHomeFeed();
}

final class RefreshHomeFeed extends HomeEvent {
  const RefreshHomeFeed();
}

final class ToggleStorySave extends HomeEvent {
  const ToggleStorySave({required this.storyId, required this.isSaved});

  final String storyId;
  final bool isSaved;

  @override
  List<Object?> get props => [storyId, isSaved];
}
