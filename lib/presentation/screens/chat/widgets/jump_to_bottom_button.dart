import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_spacing.dart';

class JumpToBottomButton extends StatelessWidget {
  const JumpToBottomButton({super.key, 
    required this.visible,
    required this.onPressed,
  });

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final motion = AppMotion.of(context, AppMotion.fast);

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        scale: visible ? 1 : 0.85,
        duration: motion,
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: motion,
          curve: AppMotion.standard,
          child: Material(
            color: colors.surface,
            elevation: 0,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: Border.all(
                    color: colors.outline,
                    width: AppSpacing.stroke,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Tooltip(
                  message: AppConstants.scrollToBottomTooltip,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
