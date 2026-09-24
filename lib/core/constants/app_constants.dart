import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Ellena';
  static const String homeHeadline = 'What can I do for you?';
  static const String composerHint = 'Assign a task or ask anything';

  static const String sendTooltip = 'Send';
  static const String stopTooltip = 'Stop';
  static const String modelTooltip = 'Model';
  static const String menuTooltip = 'Menu';
  static const String newChatTooltip = 'New chat';

  static const String chatFallbackTitle = 'Chat';
  static const String noMessages = 'No messages';
  static const String noChatsYet = 'No chats yet';
  static const String pinnedSection = 'Pinned';
  static const String recentSection = 'Recent';

  static const String interruptedLabel = 'Interrupted';
  static const String stoppedLabel = 'Stopped';
  static const String genericError = 'Something went wrong';
  static const String genericErrorRetry = 'Something went wrong · Retry';
  static const String geminiRequestFailed = 'Gemini request failed';

  static const String modelFlash20Label = '2.0 Flash';
  static const String modelFlash20Subtitle = 'Fast';
  static const String modelFlash25Label = '2.5 Flash';
  static const String modelFlash25Subtitle = 'Balanced';
  static const String modelPro25Label = '2.5 Pro';
  static const String modelPro25Subtitle = 'Stronger';

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
  static const String comingSoonMock = 'MComing soon,  for this trial.';

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
      'This removes every conversation from this device. This can’t be undone.';
  static const String deleteAllChatsConfirm = 'Delete';
  static const String deleteAllChatsCancel = 'Cancel';
  static const String deleteAllChatsDone = 'All chats deleted';

  static const List<({IconData icon, String label})> homeSuggestions = [
    (icon: Icons.slideshow_outlined, label: 'Create slides'),
    (icon: Icons.language_outlined, label: 'Build website'),
    (icon: Icons.palette_outlined, label: 'Design'),
    (icon: Icons.sports_esports_outlined, label: 'Create games'),
  ];

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
}
