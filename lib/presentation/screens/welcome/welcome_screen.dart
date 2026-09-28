import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/storage/app_storage.dart';
import '../../../data/storage/storage_keys.dart';
import '../../common_widgets/account_mark.dart';
import '../../common_widgets/app_snack_bar.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'pixel_field.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const _WelcomeBody();
}

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody();

  void _unavailable(BuildContext context) {
    HapticFeedback.selectionClick();
    AppSnackBar.show(
      context,
      message: AppConstants.signInNotConnected,
      icon: Icons.lock_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PixelField(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const AccountMark(size: 42),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppConstants.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(flex: 2),
                  const SizedBox(height: AppSpacing.xs),
                  _SignInButton(
                    mark: SvgPicture.asset(
                      'assets/icons/google.svg',
                      width: 22,
                      height: 22,
                    ),
                    label: AppConstants.continueWithGoogle,
                    onPressed: () => _unavailable(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SignInButton(
                    mark: SvgPicture.asset(
                      'assets/icons/microsoft.svg',
                      width: 18,
                      height: 18,
                    ),
                    label: AppConstants.continueWithMicrosoft,
                    onPressed: () => _unavailable(context),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          AppConstants.orLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  _SignInButton(
                    icon: Icons.mail_outline_rounded,
                    label: AppConstants.continueWithEmail,
                    onPressed: () => _unavailable(context),
                  ),
                  if (AppConfig.isDev) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _SignInButton(
                      icon: Icons.code_rounded,
                      label: AppConstants.loginAsDev,
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        await AppStorage.save(StorageKeys.signedIn, true);
                        if (!context.mounted) return;
                        context.go(AppRoutes.home);
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: _WelcomeLink(
                            label: AppConstants.forgotPassword,
                            onTap: () => _unavailable(context),
                          ),
                        ),
                        const TextSpan(text: '  or  '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: _WelcomeLink(
                            label: AppConstants.restoreAccount,
                            onTap: () => _unavailable(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _LegalFooter(
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.mark,
  });

  final IconData? icon;
  final Widget? mark;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadii.md);
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: radius,
          border: Border.all(color: colors.outline),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: Center(
                      child:
                          mark ?? Icon(icon, size: 20, color: colors.onSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeLink extends StatelessWidget {
  const _WelcomeLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.onSurface,
          decoration: TextDecoration.underline,
          decorationColor: colors.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final link = style?.copyWith(decoration: TextDecoration.underline);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      children: [
        Text(AppConstants.termsOfService, style: link),
        Text(AppConstants.privacyPolicy, style: link),
        Text(AppConstants.welcomeCopyright, style: style),
      ],
    );
  }
}
