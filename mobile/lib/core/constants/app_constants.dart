abstract final class AppConstants {
  static const appName = 'Northstar';
  static const tagline = 'Your north star in tech.';
  static const subtitle = 'Know what matters. Skip the noise.';

  /// Free tech/AI news — no API key required
  static const newsApiUrl = 'https://whatstrending.ai/api/articles';

  /// Backup free news search — no API key
  static const freeNewsApiUrl = 'https://freenewsapi.ai/v1/search';

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
