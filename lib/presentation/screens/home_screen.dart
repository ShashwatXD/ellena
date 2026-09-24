import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_shell.dart';
import '../widgets/suggestion_chips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startChat(BuildContext context, WidgetRef ref, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final id = ref.read(chatProvider.notifier).startConversation(trimmed);
    context.go(AppRoutes.chatPath(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => ChatShell.scaffoldKey.currentState?.openDrawer(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text(
          AppConstants.appName.toLowerCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.homeHeadline,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ChatComposer(
                      placement: ComposerPlacement.hero,
                      hintText: AppConstants.composerHint,
                      onSend: (text) => _startChat(context, ref, text),
                    ),
                    const SizedBox(height: 20),
                    SuggestionChips(
                      suggestions: AppConstants.homeSuggestions,
                      onSelected: (value) => _startChat(context, ref, value),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
