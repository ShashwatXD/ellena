import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../common_widgets/app_top_bar.dart';
import '../../common_widgets/chat_composer/chat_composer.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../chat/chat_screen.dart';
import 'widgets/tasks_pane.dart';
import 'widgets/typing_headline.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pages;
  var _fromSwipe = false;

  @override
  void initState() {
    super.initState();
    _pages = PageController(initialPage: WorkspaceTab.agent.index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _startChat(String text) {
    final trimmed = text.trim();
    final hasFile = ref.read(composerAttachmentProvider) != null;
    if (trimmed.isEmpty && !hasFile) return;
    ref.read(chatProvider.notifier).startConversation(trimmed);
  }

  void _onPageChanged(int index) {
    final next = WorkspaceTab.values[index];
    if (ref.read(workspaceTabProvider) == next) return;
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    _fromSwipe = true;
    ref.read(workspaceTabProvider.notifier).select(next);
    _fromSwipe = false;
  }

  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(
      chatProvider.select((s) => s.activeConversationId),
    );

    ref.listen(workspaceTabProvider, (previous, next) {
      if (_fromSwipe || !_pages.hasClients) return;
      if (_pages.page?.round() == next.index) return;
      _pages.animateToPage(
        next.index,
        duration: AppMotion.of(context, AppMotion.normal),
        curve: AppMotion.standard,
      );
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const AppTopBar(),
      body: PageView(
        controller: _pages,
        onPageChanged: _onPageChanged,
        children: [
          const TasksPane(),
          activeId == null
              ? _AgentHome(onSend: _startChat)
              : ChatScreen(key: ValueKey(activeId), conversationId: activeId),
        ],
      ),
    );
  }
}

class _AgentHome extends StatelessWidget {
  const _AgentHome({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pagePad = AppBreakpoints.pagePadding(context);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > AppSpacing.xxl
                        ? constraints.maxHeight - AppSpacing.xxl
                        : 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: pagePad + 8),
                        child: TypingHeadline(
                          text: AppConstants.homeHeadline,
                          style: AppBreakpoints.headlineStyle(context, theme),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ChatComposer(onSend: onSend),
      ],
    );
  }
}
