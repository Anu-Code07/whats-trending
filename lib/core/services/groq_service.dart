import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GroqService {
  GroqService({required this.apiKey});

  final String apiKey;

  bool get isConfigured => apiKey.isNotEmpty;

  Future<String?> enrichStory({
    required String title,
    required String summary,
    required String source,
    String depth = 'normal',
  }) async {
    if (!isConfigured) return null;

    final depthInstruction = switch (depth) {
      'quick' => 'In 1-2 sentences, ultra concise.',
      'deep' => 'In 4-6 sentences with technical context for developers.',
      _ => 'In 2-3 sentences with practical context.',
    };

    try {
      final response = await http.post(
        Uri.parse(AppConstants.groqApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a tech intelligence assistant for developers. '
                  'Explain why tech news matters. Be factual — only use the provided summary. '
                  'Do not invent details. Be concise and practical.',
            },
            {
              'role': 'user',
              'content':
                  'Story: "$title"\n'
                  'Source: $source\n'
                  'Summary: $summary\n\n'
                  'Write "Why it matters" — $depthInstruction',
            },
          ],
          'max_tokens': depth == 'deep' ? 300 : 150,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      return (choices[0] as Map)['message']?['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> generateRelevanceExplanation({
    required String title,
    required String category,
    required List<String> userInterests,
  }) async {
    if (!isConfigured || userInterests.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(AppConstants.groqApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Write one short sentence explaining why this story is relevant to the user. '
                  'Be personal and concise. Max 15 words.',
            },
            {
              'role': 'user',
              'content':
                  'Story: "$title" (category: $category)\n'
                  'User interests: ${userInterests.join(", ")}',
            },
          ],
          'max_tokens': 60,
          'temperature': 0.4,
        }),
      );

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['choices']?[0]?['message']?['content']) as String?;
    } catch (_) {
      return null;
    }
  }
}
