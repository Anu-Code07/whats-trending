import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/story_model.dart';

class NewsApiException implements Exception {
  NewsApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Live tech news from the WhatsTrending API only — no generated copy.
class WhatsTrendingDatasource {
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
        Uri.parse(AppConstants.whatsTrendingApiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Northstar/1.0',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        if (_cache != null) return _cache!;
        throw NewsApiException('Tech news is unavailable right now.');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) {
        if (_cache != null) return _cache!;
        throw NewsApiException('Tech news is unavailable right now.');
      }

      final data = json['data'] as List? ?? [];
      final stories = data
          .map((item) => _mapArticle(item as Map<String, dynamic>))
          .where((story) => story.title.isNotEmpty)
          .toList();

      _cache = stories;
      _cacheTime = DateTime.now();
      return stories;
    } on NewsApiException {
      rethrow;
    } catch (_) {
      if (_cache != null) return _cache!;
      throw NewsApiException('Could not load tech news. Check your connection.');
    }
  }

  StoryModel? getById(String id) {
    return _cache?.where((s) => s.id == id || s.slug == id).firstOrNull;
  }

  StoryModel _mapArticle(Map<String, dynamic> item) {
    final slug = item['slug'] as String? ?? '';
    final category = item['category'] as String? ?? 'Technology';
    final coverage = (item['coverage'] as num?)?.toInt() ?? 1;
    final trendScore = (item['trendScore'] as num?)?.toInt() ?? 1;
    final sources = (item['sources'] as List?)?.cast<String>() ?? [];
    final summary = item['summary'] as String? ?? '';
    final apiWhy = item['whyItMatters'] as String? ??
        item['why_it_matters'] as String? ??
        '';

    return StoryModel(
      id: slug.isNotEmpty ? slug : item['link'] as String? ?? slug,
      slug: slug,
      title: item['title'] as String? ?? item['originalTitle'] as String? ?? '',
      summary: summary,
      whyItMatters: apiWhy,
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
      trendScore: trendScore,
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
}
