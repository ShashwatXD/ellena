import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_bottom_sheet.dart';

class ConnectorsSheet extends StatelessWidget {
  const ConnectorsSheet({super.key});

  static const _items = [
    _ConnectorItem(
      name: AppConstants.connectorShopify,
      icon: Icons.shopping_bag_outlined,
      color: AppColors.markGreen,
      beta: true,
    ),
    _ConnectorItem(
      name: AppConstants.connectorOutlookCalendar,
      icon: Icons.calendar_month_outlined,
      color: AppColors.avatarBlue,
    ),
    _ConnectorItem(
      name: AppConstants.connectorOutlookMail,
      icon: Icons.mail_outline,
      color: AppColors.avatarBlue,
    ),
    _ConnectorItem(
      name: AppConstants.connectorInstagramCreator,
      icon: Icons.camera_alt_outlined,
      color: AppColors.markPink,
      beta: true,
    ),
    _ConnectorItem(
      name: AppConstants.connectorGoogleCalendar,
      icon: Icons.calendar_today_outlined,
      color: AppColors.avatarBlue,
      day: '31',
    ),
    _ConnectorItem(
      name: AppConstants.connectorMetaAds,
      icon: Icons.all_inclusive,
      color: AppColors.avatarBlue,
      beta: true,
    ),
    _ConnectorItem(
      name: AppConstants.connectorGoogleWorkspace,
      icon: Icons.workspaces_outlined,
      color: AppColors.markYellow,
    ),
    _ConnectorItem(
      name: AppConstants.connectorInstagram,
      icon: Icons.camera_alt_outlined,
      color: AppColors.markPink,
      beta: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = AppBreakpoints.pagePadding(context);

    return AppBottomSheet(
      title: AppConstants.settingsConnectors,
      centeredTitle: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, AppSpacing.xs, pad, AppSpacing.lg),
        children: [
          const _ConnectorCard(
            children: [
              _ActionRow(icon: Icons.add, label: AppConstants.addConnectors),
              _ActionRow(
                icon: Icons.hub_outlined,
                label: AppConstants.manageConnectors,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ConnectorCard(
            children: [for (final item in _items) _ConnectorRow(item: item)],
          ),
        ],
      ),
    );
  }
}

class _ConnectorItem {
  const _ConnectorItem({
    required this.name,
    required this.icon,
    required this.color,
    this.beta = false,
    this.day,
  });

  final String name;
  final IconData icon;
  final Color color;
  final bool beta;
  final String? day;
}

class _ConnectorCard extends StatelessWidget {
  const _ConnectorCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 16,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.onSurface),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _ConnectorRow extends StatelessWidget {
  const _ConnectorRow({required this.item});

  final _ConnectorItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final day = item.day;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: day == null
                ? Icon(item.icon, size: 18, color: item.color)
                : Text(
                    day,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (item.beta) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Text(
                      AppConstants.betaBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            AppConstants.connectAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
