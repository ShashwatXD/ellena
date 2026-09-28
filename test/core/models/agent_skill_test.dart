import 'package:ellena/core/models/agent_skill.dart';
import 'package:ellena/core/models/mock_stream_scenario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skill search matches name and id, and empty query keeps the list', () {
    expect(AgentSkills.matching(''), AgentSkills.all);
    expect(
      AgentSkills.matching('wri').map((skill) => skill.id),
      ['write'],
    );
    expect(
      AgentSkills.matching(
        'email',
        from: AgentSkills.catalog,
      ).single.id,
      'email',
    );
  });

  test('unknown mock label falls back to markdown', () {
    expect(MockStreamScenario.byLabel('nope'), MockStreamScenario.markdown);
    expect(MockStreamScenario.errorMid.failAfterYields, 3);
    expect(MockStreamScenario.errorEarly.failure, MockStreamFailure.unavailable);
    expect(MockStreamScenario.errorMid.failure, MockStreamFailure.timedOut);
    expect(MockStreamScenario.offline.failure, MockStreamFailure.offline);
    expect(MockStreamScenario.empty.chunks, isEmpty);
  });
}
