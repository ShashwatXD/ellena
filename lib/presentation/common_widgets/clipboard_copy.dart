import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import 'app_snack_bar.dart';

abstract final class ClipboardCopy {
  static Future<void> copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
    AppSnackBar.show(
      context,
      message: AppConstants.copiedLabel,
      icon: Icons.check_rounded,
    );
  }
}
