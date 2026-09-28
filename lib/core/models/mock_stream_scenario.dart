import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum MockStreamFailure { none, unavailable, timedOut, offline }

enum MockStreamScenario {
  short,
  markdown,
  code,
  long,
  slow,
  empty,
  errorEarly,
  errorMid,
  offline;

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
        MockStreamScenario.offline => const [],
      };

  int? get failAfterYields => switch (this) {
        MockStreamScenario.errorEarly => 0,
        MockStreamScenario.errorMid => 3,
        MockStreamScenario.offline => 0,
        _ => null,
      };

  MockStreamFailure get failure => switch (this) {
        MockStreamScenario.errorEarly => MockStreamFailure.unavailable,
        MockStreamScenario.errorMid => MockStreamFailure.timedOut,
        MockStreamScenario.offline => MockStreamFailure.offline,
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
