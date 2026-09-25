import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../providers/providers.dart';

class ChatTitle extends ConsumerWidget {
  const ChatTitle({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(
      chatProvider.select(
        (state) => state.conversationById(conversationId)?.title,
      ),
    );
    return Text(
      title ?? AppConstants.chatFallbackTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
