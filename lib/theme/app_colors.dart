import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color ink = Color(0xFF2C2A26);
  static const Color inkMuted = Color(0xFF6B6860);
  static const Color mist = Color(0xFFF5F4F1);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE4E1DA);

  static const Color accent = Color(0xFF2F6F5E);
  static const Color accentSoft = Color(0xFFE4EFEA);
  static const Color accentDeep = Color(0xFF1F4D41);

  static const Color error = Color(0xFFB42318);

  static const Color primary = accent;
  static const Color seed = accent;

  static const Color backgroundLight = mist;
  static const Color surfaceLight = canvas;
  static const Color backgroundDark = Color(0xFF161513);
  static const Color surfaceDark = Color(0xFF22201C);
  static const Color onDark = Color(0xFFF5F4F1);
  static const Color lineDark = Color(0xFF34322D);
}
