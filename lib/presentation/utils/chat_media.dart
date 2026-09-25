import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/chat_attachment.dart';
import '../common_widgets/app_snack_bar.dart';

abstract final class ChatMedia {
  static Future<ChatAttachment?> camera(BuildContext context) {
    return _image(context, ImageSource.camera, camera: true);
  }

  static Future<ChatAttachment?> picture(BuildContext context) {
    return _image(context, ImageSource.gallery, camera: false);
  }

  static Future<ChatAttachment?> pdf(BuildContext context) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (picked.isEmpty) return null;
    final file = picked.first;
    final path = file.path;
    if (path == null || path.isEmpty || !context.mounted) return null;
    final known = file.lengthSync();
    final size = known != null && known > 0 ? known : await File(path).length();
    if (!context.mounted || !_fits(context, size)) return null;
    return _keep(
      sourcePath: path,
      name: file.name,
      mimeType: 'application/pdf',
      sizeBytes: size,
    );
  }

  static Future<ChatAttachment?> _image(
    BuildContext context,
    ImageSource source, {
    required bool camera,
  }) async {
    final allowed = camera
        ? await _allowCamera(context)
        : await _allowPhotos(context);
    if (!allowed || !context.mounted) return null;

    final shot = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (shot == null || !context.mounted) return null;
    final size = await shot.length();
    if (!context.mounted || !_fits(context, size)) return null;
    return _keep(
      sourcePath: shot.path,
      name: shot.name,
      mimeType: _imageMime(shot.path),
      sizeBytes: size,
    );
  }

  static bool _fits(BuildContext context, int size) {
    if (size <= AppConstants.maxAttachmentBytes) return true;
    AppSnackBar.show(context, message: AppConstants.attachmentTooLarge);
    return false;
  }

  static Future<bool> _allowCamera(BuildContext context) async {
    if (await _granted(Permission.camera)) return true;
    if (!context.mounted) return false;
    await _askSettings(
      context,
      title: AppConstants.cameraPermissionTitle,
      body: AppConstants.cameraPermissionBody,
    );
    return false;
  }

  static Future<bool> _allowPhotos(BuildContext context) async {
    if (await _granted(Permission.photos)) return true;
    if (AppConfig.isAndroid && await _granted(Permission.storage)) {
      return true;
    }
    if (!context.mounted) return false;
    await _askSettings(
      context,
      title: AppConstants.photosPermissionTitle,
      body: AppConstants.photosPermissionBody,
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

  static Future<ChatAttachment> _keep({
    required String sourcePath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory('${root.path}/attachments');
    await folder.create(recursive: true);
    final ext = _extension(name, sourcePath);
    final dest = File(
      '${folder.path}/${DateTime.now().microsecondsSinceEpoch}$ext',
    );
    await File(sourcePath).copy(dest.path);
    return ChatAttachment(
      name: name,
      mimeType: mimeType,
      path: dest.path,
      sizeBytes: sizeBytes,
    );
  }

  static String _extension(String name, String path) {
    final fromName = name.contains('.') ? '.${name.split('.').last}' : '';
    if (fromName.isNotEmpty) return fromName.toLowerCase();
    final file = path.split('/').last;
    if (!file.contains('.')) return '';
    return '.${file.split('.').last}'.toLowerCase();
  }

  static String _imageMime(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.heic') || ext.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }
}
