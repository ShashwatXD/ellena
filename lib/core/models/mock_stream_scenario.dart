import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum MockStreamFailure {
  none,
  unavailable,
  timedOut,
  offline,
  blocked,
  rateLimited,
}

enum MockStreamScenario {
  short,
  markdown,
  code,
  long,
  slow,
  empty,
  errorEarly,
  errorMid,
  offline,
  blocked,
  rateLimited,
  timedOut;

  IconData get icon => switch (this) {
    MockStreamScenario.short => Icons.short_text_rounded,
    MockStreamScenario.markdown => Icons.code_rounded,
    MockStreamScenario.code => Icons.data_object_rounded,
    MockStreamScenario.long => Icons.notes_rounded,
    MockStreamScenario.slow => Icons.hourglass_bottom_rounded,
    MockStreamScenario.empty => Icons.inbox_outlined,
    MockStreamScenario.errorEarly => Icons.error_outline_rounded,
    MockStreamScenario.errorMid => Icons.warning_amber_rounded,
    MockStreamScenario.offline => Icons.wifi_off_rounded,
    MockStreamScenario.blocked => Icons.policy_rounded,
    MockStreamScenario.rateLimited => Icons.speed_rounded,
    MockStreamScenario.timedOut => Icons.timer_off_rounded,
  };

  String get label => switch (this) {
    MockStreamScenario.short => AppConstants.mockScenarioShort,
    MockStreamScenario.markdown => AppConstants.mockScenarioMarkdown,
    MockStreamScenario.code => AppConstants.mockScenarioCode,
    MockStreamScenario.long => AppConstants.mockScenarioLong,
    MockStreamScenario.slow => AppConstants.mockScenarioSlow,
    MockStreamScenario.empty => AppConstants.mockScenarioEmpty,
    MockStreamScenario.errorEarly => AppConstants.serviceUnavailable,
    MockStreamScenario.errorMid => AppConstants.requestTimedOut,
    MockStreamScenario.offline => AppConstants.connectionFailed,
    MockStreamScenario.blocked => AppConstants.contentPolicyBlocked,
    MockStreamScenario.rateLimited => AppConstants.rateLimitReached,
    MockStreamScenario.timedOut => AppConstants.requestTimedOut,
  };

  Duration get chunkDelay => switch (this) {
    MockStreamScenario.short => const Duration(milliseconds: 90),
    MockStreamScenario.markdown => const Duration(milliseconds: 220),
    MockStreamScenario.code => const Duration(milliseconds: 140),
    MockStreamScenario.long => const Duration(milliseconds: 140),
    MockStreamScenario.slow => const Duration(milliseconds: 700),
    MockStreamScenario.empty => Duration.zero,
    MockStreamScenario.errorEarly => const Duration(milliseconds: 180),
    MockStreamScenario.errorMid => const Duration(milliseconds: 220),
    MockStreamScenario.offline => const Duration(milliseconds: 180),
    MockStreamScenario.blocked => const Duration(milliseconds: 180),
    MockStreamScenario.rateLimited => const Duration(milliseconds: 180),
    MockStreamScenario.timedOut => const Duration(milliseconds: 180),
  };

  List<String> get chunks => switch (this) {
    MockStreamScenario.short => AppConstants.mockChunksShort,
    MockStreamScenario.markdown => AppConstants.fakeStreamChunks,
    MockStreamScenario.code => AppConstants.mockChunksCode,
    MockStreamScenario.long => AppConstants.mockChunksLong,
    MockStreamScenario.slow => AppConstants.mockChunksSlow,
    MockStreamScenario.empty => const [],
    MockStreamScenario.errorEarly => AppConstants.mockChunksErrorEarly,
    MockStreamScenario.errorMid => AppConstants.mockChunksErrorMid,
    MockStreamScenario.offline ||
    MockStreamScenario.blocked ||
    MockStreamScenario.rateLimited ||
    MockStreamScenario.timedOut => const [],
  };

  int? get failAfterYields => switch (this) {
    MockStreamScenario.errorEarly ||
    MockStreamScenario.offline ||
    MockStreamScenario.blocked ||
    MockStreamScenario.rateLimited ||
    MockStreamScenario.timedOut => 0,
    MockStreamScenario.errorMid => 3,
    _ => null,
  };

  MockStreamFailure get failure => switch (this) {
    MockStreamScenario.errorEarly => MockStreamFailure.unavailable,
    MockStreamScenario.errorMid ||
    MockStreamScenario.timedOut => MockStreamFailure.timedOut,
    MockStreamScenario.offline => MockStreamFailure.offline,
    MockStreamScenario.blocked => MockStreamFailure.blocked,
    MockStreamScenario.rateLimited => MockStreamFailure.rateLimited,
    _ => MockStreamFailure.none,
  };

  static const List<MockStreamScenario> all = MockStreamScenario.values;

  static MockStreamScenario byLabel(String label) {
    for (final scenario in all) {
      if (scenario.label == label) return scenario;
    }
    return markdown;
  }
}
