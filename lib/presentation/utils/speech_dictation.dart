import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';

abstract final class SpeechDictation {
  static Future<bool> allow(BuildContext context) async {
    if (!await _granted(Permission.microphone)) {
      if (!context.mounted) return false;
      await _askSettings(
        context,
        title: AppConstants.micPermissionTitle,
        body: AppConstants.micPermissionBody,
      );
      return false;
    }
    if (!AppConfig.isIOS || await _granted(Permission.speech)) return true;
    if (!context.mounted) return false;
    await _askSettings(
      context,
      title: AppConstants.speechPermissionTitle,
      body: AppConstants.speechPermissionBody,
    );
    return false;
  }

  static Future<bool> _granted(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;
    status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  static Future<void> _askSettings(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppConstants.notNowLabel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              child: const Text(AppConstants.openSettingsLabel),
            ),
          ],
        );
      },
    );
  }
}
