import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  AppConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.geminiApiKey,
    required this.geminiModel,
    required this.enableFakeStream,
    required this.historyBaseUrl,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig.load() has not run');
    }
    return config;
  }

  static bool get isDev => _instance?.flavor == 'dev';
  static bool get isProd => _instance?.flavor == 'prod';
  static bool get isAndroid =>
      defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static const String _geminiKeyFromEnv = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  factory AppConfig.fromJson(
    Map<String, dynamic> json, {
    String geminiApiKey = '',
  }) {
    return AppConfig._(
      flavor: json['FLAVOR'] as String? ?? 'dev',
      appName: json['APP_NAME'] as String? ?? 'Ellena',
      apiBaseUrl: json['API_BASE_URL'] as String? ??
          'https://generativelanguage.googleapis.com',
      geminiApiKey: geminiApiKey,
      geminiModel: json['GEMINI_MODEL'] as String? ?? 'gemini-3.5-flash-lite',
      enableFakeStream: (json['ENABLE_FAKE_STREAM'] as String? ?? 'true')
              .toLowerCase() ==
          'true',
      historyBaseUrl: json['HISTORY_BASE_URL'] as String? ?? '',
    );
  }

  static Future<AppConfig> load() async {
    final path =
        kDebugMode ? 'assets/config/dev.json' : 'assets/config/prod.json';
    final raw = await rootBundle.loadString(path);
    _instance = AppConfig.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      geminiApiKey: _geminiKeyFromEnv,
    );
    return instance;
  }

  final String flavor;
  final String appName;
  final String apiBaseUrl;
  final String geminiApiKey;
  final String geminiModel;
  final bool enableFakeStream;
  final String historyBaseUrl;

  bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  String get reachableHistoryBaseUrl {
    if (historyBaseUrl.isEmpty || !isAndroid) return historyBaseUrl;
    return historyBaseUrl
        .replaceFirst('://localhost', '://10.0.2.2')
        .replaceFirst('://127.0.0.1', '://10.0.2.2');
  }
}
