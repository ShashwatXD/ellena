import 'package:flutter/material.dart';

class AgentSkill {
  const AgentSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.instruction,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final String instruction;
  final IconData icon;
}

abstract final class AgentSkills {
  static const research = AgentSkill(
    id: 'research',
    name: 'Research',
    description: 'Answer with a conclusion, then the facts',
    instruction:
        'You are using the Research skill. Lead with a short conclusion, then the key points. Separate what is known from what is uncertain. Prefer concrete facts over general advice.',
    icon: Icons.travel_explore_outlined,
  );

  static const write = AgentSkill(
    id: 'write',
    name: 'Write',
    description: 'Draft clear text the user can keep',
    instruction:
        'You are using the Write skill. Produce clear prose the user can use directly. Keep the structure tight and skip any preamble about being an assistant.',
    icon: Icons.edit_outlined,
  );

  static const code = AgentSkill(
    id: 'code',
    name: 'Code',
    description: 'Put working code first',
    instruction:
        'You are using the Code skill. Solve the task with working code first. Add only the explanation needed to run or change it.',
    icon: Icons.code,
  );

  static const summarize = AgentSkill(
    id: 'summarize',
    name: 'Summarize',
    description: 'Compress to the essential points',
    instruction:
        'You are using the Summarize skill. Compress the material into a few sentences, then bullet the essential points. Leave out repetition.',
    icon: Icons.notes_outlined,
  );

  static const plan = AgentSkill(
    id: 'plan',
    name: 'Plan',
    description: 'Turn the request into ordered steps',
    instruction:
        'You are using the Plan skill. Turn the request into ordered steps and name the constraints. Do not carry out the work unless the user asked you to.',
    icon: Icons.account_tree_outlined,
  );

  static const all = <AgentSkill>[research, write, code, summarize, plan];

  static const translate = AgentSkill(
    id: 'translate',
    name: 'Translate',
    description: 'Rewrite into another language and keep the meaning',
    instruction:
        'You are using the Translate skill. Rewrite the user\'s material in the language they asked for. Keep the meaning, and do not add a commentary unless they asked for one.',
    icon: Icons.translate_rounded,
  );

  static const brainstorm = AgentSkill(
    id: 'brainstorm',
    name: 'Brainstorm',
    description: 'Offer a few directions before settling on one',
    instruction:
        'You are using the Brainstorm skill. Offer a few distinct directions before recommending one. Keep each direction short.',
    icon: Icons.lightbulb_outline_rounded,
  );

  static const critique = AgentSkill(
    id: 'critique',
    name: 'Critique',
    description: 'Point out weak spots, then suggest a tighter version',
    instruction:
        'You are using the Critique skill. Name the weak spots first, then give a tighter version of the material.',
    icon: Icons.rate_review_outlined,
  );

  static const email = AgentSkill(
    id: 'email',
    name: 'Email',
    description: 'Draft a mail that is ready to send',
    instruction:
        'You are using the Email skill. Draft a mail the user can send. Include a subject when the request has one, and skip extra explanation.',
    icon: Icons.mail_outline_rounded,
  );

  static const study = AgentSkill(
    id: 'study',
    name: 'Study',
    description: 'Explain a topic in short, ordered lessons',
    instruction:
        'You are using the Study skill. Explain the topic in short, ordered lessons. Stop when the idea is clear.',
    icon: Icons.school_outlined,
  );

  static const meeting = AgentSkill(
    id: 'meeting',
    name: 'Meeting notes',
    description: 'Turn a messy transcript into decisions and owners',
    instruction:
        'You are using the Meeting notes skill. Turn the material into decisions, owners, and open questions. Leave out small talk.',
    icon: Icons.groups_outlined,
  );

  static const catalog = <AgentSkill>[
    translate,
    brainstorm,
    critique,
    email,
    study,
    meeting,
  ];

  static List<AgentSkill> matching(
    String query, {
    List<AgentSkill> from = all,
  }) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return from;
    return [
      for (final skill in from)
        if (skill.name.toLowerCase().contains(needle) ||
            skill.id.contains(needle))
          skill,
    ];
  }
}
