import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/chat_attachment.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class ComposerAttachmentBar extends StatelessWidget {
  const ComposerAttachmentBar({
    super.key,
    required this.attachment,
    required this.onClear,
  });

  final ChatAttachment attachment;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: colors.surface,
        elevation: 4,
        shadowColor: colors.shadow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          child: Row(
            children: [
              _Preview(attachment: attachment),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppConstants.removeAttachmentTooltip,
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 18, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!attachment.isImage) {
      return Icon(Icons.picture_as_pdf_outlined, color: colors.onSurface);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Image.file(
        File(attachment.path),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_outlined, color: colors.onSurface);
        },
      ),
    );
  }
}
