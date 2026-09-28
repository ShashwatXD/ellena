import 'package:flutter/material.dart';

import '../../../theme/app_radii.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.lg);
    return Material(
      color: colors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? child
          : InkWell(onTap: onTap, child: child),
    );
  }
}
