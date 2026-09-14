import 'package:equatable/equatable.dart';

enum ImpactLevel { low, medium, high, critical }

class StorySource extends Equatable {
  const StorySource({
    required this.name,
    required this.url,
    required this.contentType,
  });

  final String name;
  final String url;
  final String contentType;

  @override
  List<Object?> get props => [name, url, contentType];
}

class StoryTimelineItem extends Equatable {
  const StoryTimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.occurredAt,
  });

  final String id;
  final String type;
  final String title;
  final DateTime occurredAt;

  @override
  List<Object?> get props => [id, type, title, occurredAt];
}

class CommunityReaction extends Equatable {
  const CommunityReaction({
    required this.themes,
    required this.summary,
    required this.source,
  });

  final List<String> themes;
  final String summary;
  final String source;

  @override
  List<Object?> get props => [themes, summary, source];
}

class Story extends Equatable {
  const Story({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.whyItMatters,
    required this.category,
    required this.sourceCount,
    required this.relevanceScore,
    required this.relevanceExplanation,
    required this.impact,
    required this.publishedAt,
    required this.primarySourceName,
    required this.primarySourceUrl,
    this.isSaved = false,
    this.isBreaking = false,
    this.whoShouldCare = const [],
    this.sources = const [],
    this.timeline = const [],
    this.communityReaction,
    this.quickExplanation,
    this.deepExplanation,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String whyItMatters;
  final String category;
  final int sourceCount;
  final double relevanceScore;
  final String relevanceExplanation;
  final ImpactLevel impact;
  final DateTime publishedAt;
  final String primarySourceName;
  final String primarySourceUrl;
  final bool isSaved;
  final bool isBreaking;
  final List<String> whoShouldCare;
  final List<StorySource> sources;
  final List<StoryTimelineItem> timeline;
  final CommunityReaction? communityReaction;
  final String? quickExplanation;
  final String? deepExplanation;

  int get relevancePercent => (relevanceScore * 100).round();

  Story copyWith({
    bool? isSaved,
    String? summary,
    String? whyItMatters,
    String? relevanceExplanation,
    double? relevanceScore,
  }) {
    return Story(
      id: id,
      slug: slug,
      title: title,
      summary: summary ?? this.summary,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      category: category,
      sourceCount: sourceCount,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      relevanceExplanation: relevanceExplanation ?? this.relevanceExplanation,
      impact: impact,
      publishedAt: publishedAt,
      primarySourceName: primarySourceName,
      primarySourceUrl: primarySourceUrl,
      isSaved: isSaved ?? this.isSaved,
      isBreaking: isBreaking,
      whoShouldCare: whoShouldCare,
      sources: sources,
      timeline: timeline,
      communityReaction: communityReaction,
      quickExplanation: quickExplanation,
      deepExplanation: deepExplanation,
    );
  }

  @override
  List<Object?> get props => [id, title, relevanceScore, isSaved];
}

class FeedData extends Equatable {
  const FeedData({
    required this.greeting,
    required this.sinceLastChecked,
    required this.stories,
  });

  final String greeting;
  final List<Story> sinceLastChecked;
  final List<Story> stories;

  @override
  List<Object?> get props => [greeting, sinceLastChecked, stories];
}
