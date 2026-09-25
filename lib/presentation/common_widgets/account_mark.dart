import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountMark extends StatelessWidget {
  const AccountMark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      'assets/icons/account.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
