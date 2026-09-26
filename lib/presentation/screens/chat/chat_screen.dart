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
  final _scrollController = ScrollController(initialScrollOffset: 1000000000);
  bool _showJumpToBottom = false;
  bool _stickToBottom = true;
  double? _bodyHeight;
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
    _stickToBottom = _isNearBottom;
    final show = !_isNearBottom;
    if (show != _showJumpToBottom) {
      setState(() => _showJumpToBottom = show);
    }
  }

  void _scrollToBottom({bool force = false}) {
    final stick = force || _stickToBottom;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients || !stick) return;
      final position = _scrollController.position;
      if (!position.hasContentDimensions) return;
      final target = position.maxScrollExtent;
      if ((target - position.pixels).abs() < 1) return;
      _scrollController.animateTo(
        target,
        duration: AppMotion.of(context, AppMotion.fast),
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
      final nextLast = nextMessages.isEmpty ? null : nextMessages.last;
      final prevLast = prevMessages.isEmpty ? null : prevMessages.last;
      if (nextMessages.length != prevMessages.length ||
          nextLast?.content != prevLast?.content ||
          nextLast?.status != prevLast?.status ||
          nextLast?.error != prevLast?.error) {
        _scrollToBottom();
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final previous = _bodyHeight;
        _bodyHeight = height;
        if (previous != null && height < previous - 1 && _stickToBottom) {
          _scrollToBottom(force: true);
        }
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
                    SingleChildScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        pagePad,
                        AppSpacing.sm,
                        pagePad,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < messageIds.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.md),
                            MessageBubble(
                              key: ValueKey(messageIds[i]),
                              conversationId: widget.conversationId,
                              messageId: messageIds[i],
                            ),
                          ],
                        ],
                      ),
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
      },
    );
  }
}
