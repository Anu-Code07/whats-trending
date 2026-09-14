import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/story_model.dart';

/// Fetches live tech/AI news from WhatsTrending (free, no API key).
class NewsApiDatasource {
  List<StoryModel>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 15);

  Future<List<StoryModel>> fetchArticles({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!;
    }

    try {
      final response = await http.get(
        Uri.parse(AppConstants.newsApiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return _cache ?? [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List? ?? [];

      final stories = data.map((item) => _mapArticle(item as Map<String, dynamic>)).toList();
      _cache = stories;
      _cacheTime = DateTime.now();
      return stories;
    } catch (_) {
      return _cache ?? [];
    }
  }

  StoryModel? getBySlug(String slug) {
    return _cache?.where((s) => s.slug == slug || s.id == slug).firstOrNull;
  }

  StoryModel _mapArticle(Map<String, dynamic> item) {
    final slug = item['slug'] as String? ?? '';
    final category = item['category'] as String? ?? 'Technology';
    final coverage = (item['coverage'] as num?)?.toInt() ?? 1;
    final trendScore = (item['trendScore'] as num?)?.toInt() ?? 1;
    final sources = (item['sources'] as List?)?.cast<String>() ?? [];

    return StoryModel(
      id: slug.isNotEmpty ? slug : item['link'] as String,
      slug: slug,
      title: item['title'] as String? ?? '',
      summary: item['summary'] as String? ?? '',
      whyItMatters: _defaultWhyItMatters(category),
      category: category,
      sourceCount: coverage > 1 ? coverage : sources.length.clamp(1, 99),
      relevanceScore: _computeRelevance(trendScore, coverage),
      relevanceExplanation: '',
      impact: _mapImpact(trendScore, coverage),
      publishedAt: _parseDate(item['date'] as String?),
      primarySource: {
        'name': item['source'] as String? ?? 'Unknown',
        'url': item['link'] as String? ?? '',
      },
      sources: [
        {
          'name': item['source'] as String? ?? 'Unknown',
          'url': item['link'] as String? ?? '',
          'contentType': 'journalism',
        },
        ...sources.where((s) => s != item['source']).map((s) => {
              'name': s,
              'url': '',
              'contentType': 'journalism',
            }),
      ],
      isBreaking: trendScore >= 3,
    );
  }

  String _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now().toIso8601String();
    try {
      return DateTime.parse(dateStr).toIso8601String();
    } catch (_) {
      return DateTime.now().toIso8601String();
    }
  }

  double _computeRelevance(int trendScore, int coverage) {
    final base = 0.65 + (trendScore * 0.08) + (coverage * 0.03);
    return base.clamp(0.5, 0.98);
  }

  String _mapImpact(int trendScore, int coverage) {
    if (trendScore >= 4 || coverage >= 5) return 'critical';
    if (trendScore >= 3 || coverage >= 3) return 'high';
    if (trendScore >= 2) return 'medium';
    return 'low';
  }

  String _defaultWhyItMatters(String category) {
    return switch (category.toLowerCase()) {
      'models' => 'A significant development in AI models that could affect how developers build with AI.',
      'tools' => 'New developer tools can change workflows and productivity for engineering teams.',
      'startups' => 'Startup moves signal where venture capital and innovation are heading in tech.',
      'regulation' => 'Policy changes can reshape how AI and technology companies operate.',
      'research' => 'Research breakthroughs often become product features within months.',
      _ => 'This development is gaining attention across the technology community.',
    };
  }
}
