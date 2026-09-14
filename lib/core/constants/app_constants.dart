abstract final class AppConstants {
  static const appName = 'Northstar';
  static const tagline = 'Your north star in tech.';
  static const subtitle = 'Know what matters. Skip the noise.';

  /// WhatsTrending — free tech/AI news, no API key required
  static const whatsTrendingApiUrl = 'https://whatstrending.ai/api/articles';

  static const groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const groqModel = 'llama-3.3-70b-versatile';

  static const availableInterests = [
    'AI',
    'Programming',
    'Startups',
    'Flutter',
    'React',
    'React Native',
    'iOS',
    'Android',
    'Web',
    'Cloud',
    'Cybersecurity',
    'Open Source',
    'DevTools',
    'Hardware',
    'Gaming',
    'Robotics',
    'Fintech',
    'Space',
  ];
}
