abstract final class AppConstants {
  static const appName = 'Northstar';
  static const tagline = 'Your north star in tech.';
  static const headline = 'Tech news,\nfiltered for you.';
  static const subtitle = 'Personalized updates. Real signal. Less noise.';

  /// WhatsTrending — live tech news API, no API key required
  static const whatsTrendingApiUrl = 'https://whatstrending.ai/api/articles';

  static const featuredInterests = [
    'AI',
    'Startups',
    'Programming',
    'Apple',
    'Android',
    'Gaming',
    'Cybersecurity',
    'Science',
    'Flutter',
    'Design',
    'Business',
    'Space',
  ];

  static const availableInterests = [
    ...featuredInterests,
    'React',
    'iOS',
    'Cloud',
    'Open Source',
    'DevTools',
    'Hardware',
    'Robotics',
    'Fintech',
  ];
}
