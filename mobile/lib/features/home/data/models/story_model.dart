import '../../domain/entities/story.dart';

class StoryModel {
  StoryModel({
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
    required this.primarySource,
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
  final String impact;
  final String publishedAt;
  final Map<String, String> primarySource;
  final bool isSaved;
  final bool isBreaking;
  final List<String> whoShouldCare;
  final List<Map<String, String>> sources;
  final List<Map<String, dynamic>> timeline;
  final Map<String, dynamic>? communityReaction;
  final String? quickExplanation;
  final String? deepExplanation;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String,
      summary: json['summary'] as String,
      whyItMatters: json['whyItMatters'] as String? ?? '',
      category: json['category'] as String,
      sourceCount: json['sourceCount'] as int? ?? 1,
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.5,
      relevanceExplanation: json['relevanceExplanation'] as String? ?? '',
      impact: json['impact'] as String? ?? 'medium',
      publishedAt: json['publishedAt'] as String,
      primarySource: Map<String, String>.from(json['primarySource'] as Map),
      isSaved: json['isSaved'] as bool? ?? false,
      isBreaking: json['isBreaking'] as bool? ?? false,
      whoShouldCare: (json['whoShouldCare'] as List?)?.cast<String>() ?? [],
      sources: (json['sources'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      timeline: (json['timeline'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      communityReaction: json['communityReaction'] as Map<String, dynamic>?,
      quickExplanation: json['quickExplanation'] as String?,
      deepExplanation: json['deepExplanation'] as String?,
    );
  }

  Story toEntity() {
    return Story(
      id: id,
      slug: slug,
      title: title,
      summary: summary,
      whyItMatters: whyItMatters,
      category: category,
      sourceCount: sourceCount,
      relevanceScore: relevanceScore,
      relevanceExplanation: relevanceExplanation,
      impact: _parseImpact(impact),
      publishedAt: DateTime.parse(publishedAt),
      primarySourceName: primarySource['name'] ?? '',
      primarySourceUrl: primarySource['url'] ?? '',
      isSaved: isSaved,
      isBreaking: isBreaking,
      whoShouldCare: whoShouldCare,
      sources: sources
          .map(
            (s) => StorySource(
              name: s['name'] ?? '',
              url: s['url'] ?? '',
              contentType: s['contentType'] ?? 'journalism',
            ),
          )
          .toList(),
      timeline: timeline
          .map(
            (t) => StoryTimelineItem(
              id: t['id'] as String,
              type: t['type'] as String,
              title: t['title'] as String,
              occurredAt: DateTime.parse(t['occurredAt'] as String),
            ),
          )
          .toList(),
      communityReaction: communityReaction != null
          ? CommunityReaction(
              themes: (communityReaction!['themes'] as List).cast<String>(),
              summary: communityReaction!['summary'] as String,
              source: communityReaction!['source'] as String,
            )
          : null,
      quickExplanation: quickExplanation,
      deepExplanation: deepExplanation,
    );
  }

  static ImpactLevel _parseImpact(String value) {
    return switch (value) {
      'critical' => ImpactLevel.critical,
      'high' => ImpactLevel.high,
      'low' => ImpactLevel.low,
      _ => ImpactLevel.medium,
    };
  }
}
