import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.geminiApiKey,
    required this.geminiModel,
    required this.enableFakeStream,
  });

  static late AppConfig current;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      flavor: json['FLAVOR'] as String? ?? 'dev',
      appName: json['APP_NAME'] as String? ?? 'Ellena',
      apiBaseUrl: json['API_BASE_URL'] as String? ??
          'https://generativelanguage.googleapis.com',
      geminiApiKey: json['GEMINI_API_KEY'] as String? ?? '',
      geminiModel: json['GEMINI_MODEL'] as String? ?? 'gemini-2.0-flash',
      enableFakeStream: (json['ENABLE_FAKE_STREAM'] as String? ?? 'true')
              .toLowerCase() ==
          'true',
    );
  }

  static Future<AppConfig> load() async {
    final path =
        kDebugMode ? 'assets/config/dev.json' : 'assets/config/prod.json';
    final raw = await rootBundle.loadString(path);
    current = AppConfig.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    return current;
  }

  final String flavor;
  final String appName;
  final String apiBaseUrl;
  final String geminiApiKey;
  final String geminiModel;
  final bool enableFakeStream;

  bool get isDev => flavor == 'dev';
  bool get isProd => flavor == 'prod';
  bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}
