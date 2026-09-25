import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/agent_skill.dart';
import '../../common_widgets/app_snack_bar.dart';
import '../../navigation/app_routes.dart';
import '../../providers/providers.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../account/widgets/account_circle_icon_button.dart';
import '../account/widgets/account_settings_card.dart';
import 'widgets/skill_hub_tile.dart';

class SkillHubScreen extends ConsumerStatefulWidget {
  const SkillHubScreen({super.key});

  @override
  ConsumerState<SkillHubScreen> createState() => _SkillHubScreenState();
}

class _SkillHubScreenState extends ConsumerState<SkillHubScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(String name, String description) {
    final needle = _query.text.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle) ||
        description.toLowerCase().contains(needle);
  }

  void _back() {
    HapticFeedback.selectionClick();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mine = ref.watch(mySkillsProvider);
    final mineIds = {for (final skill in mine) skill.id};
    final builtIn = {for (final skill in AgentSkills.all) skill.id};
    final shownMine = [
      for (final skill in mine)
        if (_matches(skill.name, skill.description)) skill,
    ];
    final explore = [
      for (final skill in AgentSkills.catalog)
        if (!mineIds.contains(skill.id) &&
            _matches(skill.name, skill.description))
          skill,
    ];

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: true,
        leadingWidth: AppBreakpoints.isCompact(context) ? 56 : 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: Center(
            child: AccountCircleIconButton(
              tooltip: AppConstants.backTooltip,
              icon: Icons.chevron_left_rounded,
              onPressed: _back,
            ),
          ),
        ),
        title: Text(
          AppConstants.skillHubTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppBreakpoints.pagePadding(context),
            AppSpacing.sm,
            AppBreakpoints.pagePadding(context),
            AppSpacing.xxl,
          ),
          children: [
            Text(
              AppConstants.skillHubSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppConstants.skillHubSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide: BorderSide(color: colors.outline),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  AppSnackBar.show(
                    context,
                    message: AppConstants.comingSoonMock,
                    icon: Icons.hub_outlined,
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(AppConstants.skillHubCreate),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(
              label: AppConstants.skillHubMySkills,
              count: shownMine.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (shownMine.isEmpty)
              _EmptyLine(text: AppConstants.noSkillsLabel)
            else
              AccountSettingsCard(
                child: Column(
                  children: [
                    for (var i = 0; i < shownMine.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: AppSpacing.stroke,
                          color: colors.outline.withValues(alpha: 0.7),
                        ),
                      SkillHubTile(
                        icon: shownMine[i].icon,
                        name: shownMine[i].name,
                        description: shownMine[i].description,
                        added: true,
                        onAdd: builtIn.contains(shownMine[i].id)
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(mySkillsProvider.notifier)
                                    .remove(shownMine[i]);
                              },
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(
              label: AppConstants.skillHubExplore,
              count: explore.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (explore.isEmpty)
              _EmptyLine(text: AppConstants.noSkillsLabel)
            else
              AccountSettingsCard(
                child: Column(
                  children: [
                    for (var i = 0; i < explore.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: AppSpacing.stroke,
                          color: colors.outline.withValues(alpha: 0.7),
                        ),
                      SkillHubTile(
                        icon: explore[i].icon,
                        name: explore[i].name,
                        description: explore[i].description,
                        onAdd: () {
                          HapticFeedback.selectionClick();
                          ref.read(mySkillsProvider.notifier).add(explore[i]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$count',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
