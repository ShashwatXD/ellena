import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/llm_model.dart';
import 'app_config_provider.dart';

final selectedModelProvider =
    NotifierProvider<SelectedModelNotifier, LlmModel>(SelectedModelNotifier.new);

class SelectedModelNotifier extends Notifier<LlmModel> {
  @override
  LlmModel build() {
    final config = ref.watch(appConfigProvider);
    return GeminiModels.byId(config.geminiModel);
  }

  void select(LlmModel model) => state = model;
}
