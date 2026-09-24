import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../theme/app_spacing.dart';
import '../../../common_widgets/app_snack_bar.dart';
import '../../../providers/providers.dart';
import 'account_settings_card.dart';

class AccountMockResponsesCard extends ConsumerWidget {
  const AccountMockResponsesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = ref.watch(useFakeStreamProvider);

    return AccountSettingsCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.science_outlined,
              size: 22,
              color: colors.onSurface.withValues(alpha: 0.85),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                AppConstants.mockResponsesLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch.adaptive(
              value: enabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref.read(useFakeStreamProvider.notifier).setEnabled(value);
                AppSnackBar.show(
                  context,
                  message: value
                      ? AppConstants.usingMockStream
                      : AppConstants.usingGeminiStream,
                  icon: value
                      ? Icons.science_outlined
                      : Icons.auto_awesome_outlined,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
