import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../providers/providers.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../widgets/chat_composer.dart';
import '../widgets/ellena_app_bar.dart';
import '../widgets/mock_scenario_picker.dart';
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
    final pagePad = AppBreakpoints.pagePadding(context);
    final gap = AppBreakpoints.sectionGap(context);
    final compact = AppBreakpoints.isCompact(context);
    final config = ref.watch(appConfigProvider);
    final useFake = ref.watch(useFakeStreamProvider);
    final showMockChips = config.isDev && useFake;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: EllenaAppBar(
        title: Text(
          AppConstants.appName.toLowerCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                0,
                compact ? AppSpacing.md : AppSpacing.lg,
                0,
                gap + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      (compact ? AppSpacing.lg : AppSpacing.xxl),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: AppMotion.of(context, AppMotion.emphasis),
                      curve: AppMotion.standard,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 10),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: pagePad + 8),
                        child: Text(
                          AppConstants.homeHeadline,
                          style: AppBreakpoints.headlineStyle(context, theme),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: gap),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: AppMotion.of(context, AppMotion.emphasis),
                      curve: AppMotion.standard,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 12),
                            child: child,
                          ),
                        );
                      },
                      child: ChatComposer(
                        placement: ComposerPlacement.hero,
                        hintText: AppConstants.composerHint,
                        onSend: (text) => _startChat(context, ref, text),
                      ),
                    ),
                    SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                    if (showMockChips)
                      MockScenarioPicker(
                        onSelected: (scenario) =>
                            _startChat(context, ref, scenario.label),
                      )
                    else
                      SuggestionChips(
                        suggestions: AppConstants.homeSuggestions,
                        onSelected: (value) =>
                            _startChat(context, ref, value),
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
