import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/chat_composer.dart';
import '../widgets/ellena_app_bar.dart';
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: EllenaAppBar(
        title: Text(
          AppConstants.appName.toLowerCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                0,
                AppSpacing.lg,
                0,
                AppSpacing.lg + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        AppConstants.homeHeadline,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ChatComposer(
                      placement: ComposerPlacement.hero,
                      hintText: AppConstants.composerHint,
                      onSend: (text) => _startChat(context, ref, text),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
