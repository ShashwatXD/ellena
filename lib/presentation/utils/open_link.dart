import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class OpenLink {
  static Future<bool> open(String raw) async {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
