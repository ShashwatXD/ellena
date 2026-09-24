import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';

class AccountCircleIconButton extends StatelessWidget {
  const AccountCircleIconButton({super.key, 
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(
          side: BorderSide(
            color: colors.outline.withValues(alpha: 0.85),
            width: AppSpacing.stroke,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}
