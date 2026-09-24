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
  static const flash20 = LlmModel(
    id: 'gemini-2.0-flash',
    label: AppConstants.modelFlash20Label,
    subtitle: AppConstants.modelFlash20Subtitle,
  );

  static const flash25 = LlmModel(
    id: 'gemini-2.5-flash',
    label: AppConstants.modelFlash25Label,
    subtitle: AppConstants.modelFlash25Subtitle,
  );

  static const pro25 = LlmModel(
    id: 'gemini-2.5-pro',
    label: AppConstants.modelPro25Label,
    subtitle: AppConstants.modelPro25Subtitle,
  );

  static const List<LlmModel> all = [flash20, flash25, pro25];

  static LlmModel byId(String id) {
    for (final model in all) {
      if (model.id == id) return model;
    }
    return flash20;
  }
}
