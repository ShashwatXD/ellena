import 'package:ellena/core/models/agent_skill.dart';
import 'package:ellena/presentation/providers/skill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer container() {
    final scope = ProviderContainer();
    addTearDown(scope.dispose);
    return scope;
  }

  test('built-in skills start installed and cannot be removed', () {
    final scope = container();
    final skills = scope.read(mySkillsProvider.notifier);

    expect(skills.owns(AgentSkills.research.id), isTrue);

    skills.remove(AgentSkills.research);
    expect(scope.read(mySkillsProvider), AgentSkills.all);
  });

  test('adding a catalog skill is idempotent and removing it clears the chip', () {
    final scope = container();
    final skills = scope.read(mySkillsProvider.notifier);

    skills.add(AgentSkills.translate);
    skills.add(AgentSkills.translate);
    expect(
      scope.read(mySkillsProvider).where((skill) => skill.id == 'translate'),
      hasLength(1),
    );

    scope.read(selectedSkillProvider.notifier).select(AgentSkills.translate);
    skills.remove(AgentSkills.translate);

    expect(skills.owns('translate'), isFalse);
    expect(scope.read(selectedSkillProvider), isNull);
  });
}
