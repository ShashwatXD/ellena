import '../constants/app_constants.dart';

class LlmModel {
  const LlmModel({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;
}

abstract final class GeminiModels {
  static const flashLite = LlmModel(
    id: 'gemini-3.5-flash-lite',
    label: AppConstants.modelFlashLiteLabel,
    subtitle: AppConstants.modelFlashLiteSubtitle,
  );

  static const flash = LlmModel(
    id: 'gemini-3.5-flash',
    label: AppConstants.modelFlashLabel,
    subtitle: AppConstants.modelFlashSubtitle,
  );

  static const pro = LlmModel(
    id: 'gemini-3.1-pro-preview',
    label: AppConstants.modelProLabel,
    subtitle: AppConstants.modelProSubtitle,
  );

  static const List<LlmModel> all = [flashLite, flash, pro];

  static LlmModel byId(String id) {
    for (final model in all) {
      if (model.id == id) return model;
    }
    return flash;
  }
}
