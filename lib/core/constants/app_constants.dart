import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Ellena';
  static const String homeHeadline = 'What can I do for you?';
  static const String composerHint = 'Ask anything';

  static const String sendTooltip = 'Send';
  static const String stopTooltip = 'Stop';
  static const String scrollToBottomTooltip = 'Jump to latest';
  static const String modelTooltip = 'Model';
  static const String menuTooltip = 'Menu';
  static const String newChatTooltip = 'New chat';
  static const String newChatLabel = 'New chat';
  static const String chatActionsTooltip = 'Chat actions';
  static const String pinChatLabel = 'Pin';
  static const String unpinChatLabel = 'Unpin';
  static const String renameChatLabel = 'Rename';
  static const String deleteChatLabel = 'Delete';
  static const String renameChatTitle = 'Rename chat';
  static const String renameChatHint = 'Title';
  static const String renameChatSave = 'Save';
  static const String renameChatCancel = 'Cancel';
  static const String deleteChatTitle = 'Delete chat?';
  static const String deleteChatBody =
      'This removes the conversation from this device.';
  static const String deleteChatConfirm = 'Delete';
  static const String deleteChatCancel = 'Cancel';

  static const String chatFallbackTitle = 'Chat';
  static const String noMessages = 'No messages';
  static const String noChatsYet = 'No chats yet';
  static const String pinnedSection = 'Pinned';
  static const String recentSection = 'Recent';

  static const String interruptedLabel = 'Interrupted';
  static const String stoppedLabel = 'Stopped';
  static const String genericError = 'Something went wrong';
  static const String retryLabel = 'Retry';
  static const String knowMoreLabel = 'Know more';
  static const String showLessLabel = 'Show less';
  static const String copiedLabel = 'Copied';
  static const String copyTooltip = 'Copy';
  static const String geminiRequestFailed = 'Request failed';
  static const String rateLimitReached = 'Rate limit reached';
  static const String contentPolicyBlocked = 'Blocked by content policy';
  static const String authenticationFailed = 'Authentication failed';
  static const String invalidRequest = 'Invalid request';
  static const String modelNotFound = 'Model not found';
  static const String serverError = 'Server error';
  static const String serviceUnavailable =
      'Service temporarily unavailable';
  static const String requestTimedOut = 'Request timed out';
  static const String connectionFailed = 'Connection failed';
  static const String noInternetConnection = 'No internet connection';
  static const String titlePromptPrefix =
      'Reply with a 3-6 word chat title only. No quotes or punctuation.\n\n';

  static const String modelFlashLiteLabel = '3.5 Flash-Lite';
  static const String modelFlashLiteSubtitle = 'Fast';
  static const String modelFlashLabel = '3.8 Flash';
  static const String modelFlashSubtitle = 'Balanced';
  static const String modelProLabel = '3.1 Pro';
  static const String modelProSubtitle = 'Stronger';

  static const String settingsTitle = 'Settings';
  static const String accountTooltip = 'Account';
  static const String backTooltip = 'Back';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String themeSystem = 'System';

  static const String mockUserName = 'Shashwat Test';
  static const String mockUserEmail = 'shashwat.sandbox@gmail.com';
  static const String mockPlanName = 'Free';
  static const String upgradeLabel = 'Upgrade';
  static const String creditsLabel = 'Credits';
  static const String creditsValue = '2K';
  static const String comingSoonMock = 'Mocked for this trial.';

  static const String settingsScheduledTasks = 'Scheduled tasks';
  static const String settingsKnowledge = 'Knowledge';
  static const String settingsMail = 'Mail Ellena';
  static const String settingsDataControls = 'Data controls';
  static const String settingsCloudBrowser = 'Cloud Browser';
  static const String settingsSkills = 'Skills';
  static const String settingsConnectors = 'Connectors';
  static const String settingsIntegrations = 'Integrations';
  static const String deleteAllChatsLabel = 'Delete all chats';
  static const String deleteAllChatsTitle = 'Delete all chats?';
  static const String deleteAllChatsBody =
      'This removes every conversation from this device. This can\'t be undone.';
  static const String deleteAllChatsConfirm = 'Delete';
  static const String deleteAllChatsCancel = 'Cancel';
  static const String deleteAllChatsDone = 'All chats deleted';

  static const String mockResponsesLabel = 'Mock responses';
  static const String usingMockStream = 'Using mock stream';
  static const String usingGeminiStream = 'Using Gemini';

  static const List<({IconData icon, String label})> homeSuggestions = [
    (icon: Icons.slideshow_outlined, label: 'Create slides'),
    (icon: Icons.language_outlined, label: 'Build website'),
    (icon: Icons.palette_outlined, label: 'Design'),
    (icon: Icons.sports_esports_outlined, label: 'Create games'),
  ];

  static const String mockScenarioShort = 'Short';
  static const String mockScenarioMarkdown = 'Markdown';
  static const String mockScenarioLong = 'Long';
  static const String mockScenarioSlow = 'Slow';
  static const String mockScenarioEmpty = 'Empty';
  static const String mockScenarioErrorEarly = 'Fail early';
  static const String mockScenarioErrorMid = 'Fail mid';
  static const String mockScenarioOffline = 'No internet';
  static const String mockStreamFailed = 'Mock stream failed';

  static const List<String> fakeStreamChunks = [
    '## Quick answer\n\n',
    'Here is a **markdown** demo while we wait on a live Gemini key.\n\n',
    '- Model selector is wired through the same stream path\n',
    '- Streaming works the same for fake and Gemini\n',
    '- Stop keeps only what already arrived\n\n',
    '```dart\n',
    'streamingService.streamReply(prompt: prompt, model: model);\n',
    '```\n\n',
    '| Mode | Source |\n',
    '| --- | --- |\n',
    '| Fake | Local scripted chunks |\n',
    '| Gemini | `streamGenerateContent` SSE |\n\n',
    'Ask anything else when you are ready.',
  ];

  static const List<String> mockChunksShort = [
    'Short reply - scenario picker is working.',
  ];

  static const List<String> mockChunksSlow = [
    'This ',
    'stream ',
    'is ',
    'intentionally ',
    'slow ',
    'so you can tap Stop mid-flight.',
  ];

  static const List<String> mockChunksErrorEarly = [
    'unreachable',
  ];

  static const List<String> mockChunksErrorMid = [
    'Partial answer so far.\n\n',
    'Next chunk arrives...\n\n',
    'One more before the failure...\n\n',
    'This chunk should not appear.',
  ];

  static const List<String> mockChunksLong = [
    '## Long stream\n\n',
    'This scenario is meant to stress scroll, markdown, and bubble growth while tokens arrive.\n\n',
    '### 1. Formatting\n\n',
    'Here is **bold**, *italic*, ~~strike~~, and `inline code` in one paragraph so the renderer stays busy.\n\n',
    '### 2. Lists\n\n',
    'Ordered steps:\n',
    '1. Open the chat\n',
    '2. Pick **Long**\n',
    '3. Watch the list scroll as chunks land\n',
    '4. Try Stop mid-stream if you want a partial\n\n',
    'Unordered extras:\n',
    '- sticky bottom behavior\n',
    '- markdown tables\n',
    '- nested bullets\n',
    '  - level two\n',
    '  - another level two\n',
    '- code fences\n\n',
    '### 3. Code sample\n\n',
    '```dart\n',
    'Stream<String> streamReply({\n',
    '  required String prompt,\n',
    '  required String model,\n',
    '}) async* {\n',
    '  for (final chunk in chunks) {\n',
    '    await Future.delayed(delay);\n',
    '    yield chunk;\n',
    '  }\n',
    '}\n',
    '```\n\n',
    '### 4. Comparison table\n\n',
    '| Case | Expect | Notes |\n',
    '| --- | --- | --- |\n',
    '| Long | Many tokens | Scroll stress |\n',
    '| Stop | Partial kept | Same slot as Send |\n',
    '| Retry | Latest fail only | Tip of the thread |\n',
    '| Fake | Local script | No network |\n',
    '| Gemini | SSE | Real path |\n\n',
    '### 5. Long prose A\n\n',
    'Ellena keeps the surface calm while the stream path does the hard work. ',
    'As each chunk arrives the assistant bubble grows, the list should stick near the bottom, ',
    'and the composer stays usable with keyboard and safe areas on compact phones.\n\n',
    '### 6. Blockquote\n\n',
    '> Small polished slice beats a wide broken feature list.\n\n',
    '### 7. Long prose B\n\n',
    'When you leave this running you should see headings, lists, a fence, a table, and enough ',
    'wrapping text that a 360dp viewport needs to scroll. That is the point of this mock: ',
    'not clever copy, just volume and structure under a fake stream.\n\n',
    '### 8. Checklist\n\n',
    '- [x] Markdown headings\n',
    '- [x] Nested lists\n',
    '- [x] Code fence\n',
    '- [x] Table\n',
    '- [ ] Live Gemini (toggle mock off in Settings)\n\n',
    '### 9. Long prose C\n\n',
    'One more stretch paragraph so the bubble keeps expanding: layout tokens, restrained motion, ',
    'send and stop in the same slot, loading dots before the first token, and interrupt that freezes ',
    'whatever already arrived without flushing the rest of the script.\n\n',
    '### 10. Closing\n\n',
    'Chunk near the end - almost done.\n\n',
    'Final token - long scenario complete. You can send again or switch scenarios on home.',
  ];
}
