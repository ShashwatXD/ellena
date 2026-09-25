import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_spacing.dart';
import 'app_bottom_sheet.dart';

abstract final class SelectTextSheet {
  static const heightFactor = 0.9;

  static Future<void> show(BuildContext context, String text) {
    return AppBottomSheet.show(
      context,
      builder: (context) => AppBottomSheet(
        title: AppConstants.selectTextLabel,
        showClose: true,
        heightFactor: heightFactor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }
}
