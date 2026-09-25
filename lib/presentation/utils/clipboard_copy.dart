import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../common_widgets/app_snack_bar.dart';

abstract final class ClipboardCopy {
  static Future<void> copy(
    BuildContext context,
    String text, {
    bool notify = true,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
    if (!notify) return;
    AppSnackBar.show(
      context,
      message: AppConstants.copiedLabel,
      icon: Icons.check_rounded,
    );
  }
}
