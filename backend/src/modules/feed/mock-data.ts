import type { StoryDetail, StorySummary } from '../../shared/types/story.types.js';

export const MOCK_STORIES: StoryDetail[] = [
  {
    id: 'story-001',
    slug: 'react-major-update',
    title: 'React announces a major update with Server Components improvements',
    summary:
      'The React team released React 19.2 with significant Server Components improvements, ' +
      'better streaming SSR, and new compiler optimizations that reduce bundle sizes by up to 30%.',
    whyItMatters:
      'This update affects every React developer. The compiler optimizations mean less manual ' +
      'memoization, and improved Server Components make full-stack React apps more performant.',
    whoShouldCare: ['Developers', 'Frontend Engineers', 'Full-stack Developers'],
    category: 'Programming',
    sourceCount: 42,
    relevanceScore: 0.96,
    relevanceExplanation: 'You frequently read React and frontend performance stories.',
    impact: 'high',
    publishedAt: new Date(Date.now() - 2 * 3_600_000).toISOString(),
    primarySource: { name: 'React Blog', url: 'https://react.dev/blog' },
    isSaved: false,
    isBreaking: true,
    sources: [
      { name: 'React Blog', url: 'https://react.dev/blog', contentType: 'official' },
      { name: 'Vercel', url: 'https://vercel.com/blog', contentType: 'analysis' },
      { name: 'Hacker News', url: 'https://news.ycombinator.com', contentType: 'community' },
      { name: 'The Verge', url: 'https://theverge.com', contentType: 'journalism' },
    ],
    timeline: [
      {
        id: 'tl-001',
        type: 'breaking',
        title: 'React 19.2 announced',
        occurredAt: new Date(Date.now() - 2 * 3_600_000).toISOString(),
      },
      {
        id: 'tl-002',
        type: 'reaction',
        title: 'Developer community reacts to compiler changes',
        occurredAt: new Date(Date.now() - 1 * 3_600_000).toISOString(),
      },
    ],
    communityReaction: {
      themes: ['excitement', 'migration planning', 'performance gains'],
      summary:
        'Developers are excited about automatic memoization but some express concern about migration complexity.',
      source: 'Hacker News, Reddit r/reactjs',
    },
    quickExplanation: 'React 19.2 ships compiler optimizations and better Server Components.',
    deepExplanation:
      'React 19.2 introduces the React Compiler as stable, eliminating the need for useMemo and useCallback ' +
      'in most cases. Server Components now support partial prerendering, and streaming SSR latency improved by 40%. ' +
      'Migration: run `npx react-compiler-healthcheck` to assess your codebase.',
  },
  {
    id: 'story-002',
    slug: 'openai-developer-capability',
    title: 'OpenAI releases new developer capability for structured outputs',
    summary:
      'OpenAI launched structured outputs with JSON schema enforcement, making it reliable for ' +
      'production AI applications that need predictable response formats.',
    whyItMatters:
      'Structured outputs solve a major pain point for AI engineers building production systems. ' +
      'No more prompt engineering tricks to get valid JSON.',
    whoShouldCare: ['AI Engineers', 'Developers', 'Startups'],
    category: 'AI',
    sourceCount: 38,
    relevanceScore: 0.92,
    relevanceExplanation: 'You follow AI and developer tools.',
    impact: 'high',
    publishedAt: new Date(Date.now() - 4 * 3_600_000).toISOString(),
    primarySource: { name: 'OpenAI Blog', url: 'https://openai.com/blog' },
    isSaved: false,
    sources: [
      { name: 'OpenAI Blog', url: 'https://openai.com/blog', contentType: 'official' },
      { name: 'TechCrunch', url: 'https://techcrunch.com', contentType: 'journalism' },
    ],
    timeline: [],
    quickExplanation: 'OpenAI now enforces JSON schema on API responses.',
    deepExplanation:
      'The new structured outputs API uses constrained decoding to guarantee schema-compliant responses. ' +
      'Supports nested objects, enums, and optional fields. Latency impact is minimal (<5ms overhead).',
  },
  {
    id: 'story-003',
    slug: 'ai-coding-tool-trending',
    title: 'New open-source AI coding tool is rapidly gaining popularity',
    summary:
      'An open-source AI coding assistant built on local LLMs has gained 8,400 stars in 36 hours, ' +
      'offering privacy-focused code generation without cloud dependencies.',
    whyItMatters:
      'This signals growing developer demand for local, privacy-preserving AI tools as an alternative ' +
      'to cloud-based coding assistants.',
    whoShouldCare: ['Developers', 'AI Engineers', 'Open Source Contributors'],
    category: 'Open Source',
    sourceCount: 15,
    relevanceScore: 0.87,
    relevanceExplanation: 'Related to developer tools and AI you follow.',
    impact: 'medium',
    publishedAt: new Date(Date.now() - 6 * 3_600_000).toISOString(),
    primarySource: { name: 'GitHub', url: 'https://github.com' },
    isSaved: false,
    sources: [
      { name: 'GitHub', url: 'https://github.com', contentType: 'official' },
      { name: 'Hacker News', url: 'https://news.ycombinator.com', contentType: 'community' },
    ],
    timeline: [],
    quickExplanation: 'Local LLM coding tool hits 8.4k GitHub stars in 36 hours.',
  },
  {
    id: 'story-004',
    slug: 'major-security-vulnerability',
    title: 'Major security vulnerability discovered in widely-used npm package',
    summary:
      'A critical CVE (CVSS 9.8) was disclosed in a package with 20M weekly downloads, ' +
      'allowing remote code execution in affected applications.',
    whyItMatters:
      'If your project depends on this package, you need to update immediately. ' +
      'The vulnerability affects both server and client-side usage.',
    whoShouldCare: ['Developers', 'DevOps Engineers', 'Security Engineers'],
    category: 'Cybersecurity',
    sourceCount: 56,
    relevanceScore: 0.84,
    relevanceExplanation: 'Critical security story affecting the developer ecosystem.',
    impact: 'critical',
    publishedAt: new Date(Date.now() - 1 * 3_600_000).toISOString(),
    primarySource: { name: 'GitHub Security Advisory', url: 'https://github.com/advisories' },
    isSaved: false,
    isBreaking: true,
    sources: [
      { name: 'GitHub Advisory', url: 'https://github.com/advisories', contentType: 'official' },
      { name: 'Snyk', url: 'https://snyk.io', contentType: 'analysis' },
    ],
    timeline: [
      {
        id: 'tl-003',
        type: 'breaking',
        title: 'CVE published',
        occurredAt: new Date(Date.now() - 1 * 3_600_000).toISOString(),
      },
    ],
    quickExplanation: 'Critical RCE in npm package with 20M weekly downloads. Patch now.',
  },
  {
    id: 'story-005',
    slug: 'flutter-impeller-default',
    title: 'Flutter makes Impeller the default rendering engine on all platforms',
    summary:
      'Flutter 3.29 makes Impeller the default renderer on iOS, Android, and desktop, ' +
      'replacing Skia with a modern GPU-accelerated pipeline.',
    whyItMatters:
      'Impeller eliminates shader compilation jank and improves frame consistency. ' +
      'All Flutter developers will see performance improvements on next upgrade.',
    whoShouldCare: ['Flutter Developers', 'Mobile Developers', 'iOS Developers'],
    category: 'Flutter',
    sourceCount: 28,
    relevanceScore: 0.91,
    relevanceExplanation: 'You follow Flutter and mobile development.',
    impact: 'high',
    publishedAt: new Date(Date.now() - 8 * 3_600_000).toISOString(),
    primarySource: { name: 'Flutter Blog', url: 'https://flutter.dev' },
    isSaved: false,
    sources: [
      { name: 'Flutter Blog', url: 'https://flutter.dev', contentType: 'official' },
      { name: 'Medium', url: 'https://medium.com', contentType: 'analysis' },
    ],
    timeline: [],
    quickExplanation: 'Impeller is now default on all Flutter platforms.',
  },
  {
    id: 'story-006',
    slug: 'apple-ai-framework',
    title: 'Apple launches new on-device AI framework for developers',
    summary:
      'Apple introduced Foundation Models framework at WWDC, enabling developers to run ' +
      'Apple Intelligence models on-device with a Swift-native API.',
    whyItMatters:
      'This opens on-device AI capabilities to all iOS/macOS developers without cloud costs ' +
      'or privacy concerns. A major shift for Apple ecosystem development.',
    whoShouldCare: ['iOS Developers', 'AI Engineers', 'Startups'],
    category: 'AI',
    sourceCount: 45,
    relevanceScore: 0.78,
    relevanceExplanation: 'Major platform announcement with broad developer impact.',
    impact: 'high',
    publishedAt: new Date(Date.now() - 12 * 3_600_000).toISOString(),
    primarySource: { name: 'Apple Developer', url: 'https://developer.apple.com' },
    isSaved: false,
    sources: [
      { name: 'Apple Developer', url: 'https://developer.apple.com', contentType: 'official' },
      { name: 'Ars Technica', url: 'https://arstechnica.com', contentType: 'journalism' },
    ],
    timeline: [],
    quickExplanation: 'Apple ships on-device AI framework for Swift developers.',
  },
  {
    id: 'story-007',
    slug: 'vercel-edge-update',
    title: 'Vercel announces major Edge Runtime update with WebAssembly support',
    summary:
      'Vercel Edge Runtime now supports WebAssembly modules, enabling compute-heavy workloads ' +
      'at the edge with near-zero cold starts.',
    whyItMatters:
      'Edge WASM unlocks new architectures for global low-latency applications. ' +
      'Particularly relevant for Next.js and frontend-heavy teams.',
    whoShouldCare: ['Frontend Engineers', 'Full-stack Developers', 'Startups'],
    category: 'Cloud',
    sourceCount: 18,
    relevanceScore: 0.75,
    relevanceExplanation: 'Related to web development and cloud infrastructure.',
    impact: 'medium',
    publishedAt: new Date(Date.now() - 10 * 3_600_000).toISOString(),
    primarySource: { name: 'Vercel Blog', url: 'https://vercel.com/blog' },
    isSaved: false,
    sources: [
      { name: 'Vercel Blog', url: 'https://vercel.com/blog', contentType: 'official' },
    ],
    timeline: [],
    quickExplanation: 'Vercel Edge now runs WebAssembly for heavy compute at the edge.',
  },
];

export function toSummary(story: StoryDetail): StorySummary {
  const { sources: _s, timeline: _t, whoShouldCare: _w, communityReaction: _c, deepExplanation: _d, quickExplanation: _q, ...summary } = story;
  return summary;
}
