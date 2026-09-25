import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/agent_skill.dart';

final selectedSkillProvider =
    NotifierProvider<SelectedSkillNotifier, AgentSkill?>(
  SelectedSkillNotifier.new,
);

class SelectedSkillNotifier extends Notifier<AgentSkill?> {
  @override
  AgentSkill? build() => null;

  void select(AgentSkill skill) => state = skill;

  void clear() => state = null;
}

final skillPickerProvider =
    NotifierProvider<SkillPickerNotifier, bool>(SkillPickerNotifier.new);

class SkillPickerNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;

  void close() {
    if (!state) return;
    state = false;
  }
}

final mySkillsProvider =
    NotifierProvider<MySkillsNotifier, List<AgentSkill>>(MySkillsNotifier.new);

class MySkillsNotifier extends Notifier<List<AgentSkill>> {
  @override
  List<AgentSkill> build() => AgentSkills.all;

  bool owns(String id) => state.any((skill) => skill.id == id);

  void add(AgentSkill skill) {
    if (owns(skill.id)) return;
    state = [...state, skill];
  }

  void remove(AgentSkill skill) {
    if (AgentSkills.all.any((item) => item.id == skill.id)) return;
    state = [
      for (final item in state)
        if (item.id != skill.id) item,
    ];
    if (ref.read(selectedSkillProvider)?.id == skill.id) {
      ref.read(selectedSkillProvider.notifier).clear();
    }
  }
}
