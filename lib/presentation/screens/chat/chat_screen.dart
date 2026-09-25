import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../common_widgets/message_bubble/message_bubble.dart';
import 'widgets/chat_composer_slot.dart';
import 'widgets/jump_to_bottom_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _showJumpToBottom = false;
  static const _jumpThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= _jumpThreshold;
  }

  void _onScroll() {
    final show = !_isNearBottom;
    if (show != _showJumpToBottom) {
      setState(() => _showJumpToBottom = show);
    }
  }

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (!force && !_isNearBottom && _showJumpToBottom) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppMotion.of(context, AppMotion.normal),
        curve: AppMotion.standard,
      );
    });
  }

  void _jumpToBottom() {
    HapticFeedback.selectionClick();
    _scrollToBottom(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final messageIds = ref.watch(
      chatProvider.select(
        (state) => state
            .messagesFor(widget.conversationId)
            .map((m) => m.id)
            .toList(growable: false),
      ),
    );
    final pagePad = AppBreakpoints.pagePadding(context);

    ref.listen(chatProvider, (prev, next) {
      final nextMessages = next.messagesFor(widget.conversationId);
      final prevMessages = prev?.messagesFor(widget.conversationId) ?? const [];
      if (nextMessages.length != prevMessages.length ||
          (nextMessages.isNotEmpty &&
              prevMessages.isNotEmpty &&
              nextMessages.last.content != prevMessages.last.content)) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        Expanded(
          child: messageIds.isEmpty
              ? SafeArea(
                  top: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pagePad),
                      child: Text(
                        AppConstants.noMessages,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ListView.separated(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        pagePad,
                        AppSpacing.sm,
                        pagePad,
                        AppSpacing.lg,
                      ),
                      itemCount: messageIds.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final id = messageIds[index];
                        return MessageBubble(
                          key: ValueKey(id),
                          conversationId: widget.conversationId,
                          messageId: id,
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: AppSpacing.sm,
                      child: Center(
                        child: JumpToBottomButton(
                          visible: _showJumpToBottom,
                          onPressed: _jumpToBottom,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        ChatComposerSlot(conversationId: widget.conversationId),
      ],
    );
  }
}
