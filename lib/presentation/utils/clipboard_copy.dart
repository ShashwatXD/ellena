import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class ClipboardCopy {
  static Future<void> copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
  }
}
