import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Ellena';
  static const String homeHeadline = 'What can I do for you?';
  static const String composerHint = 'Assign a task or ask anything';

  static const List<({IconData icon, String label})> homeSuggestions = [
    (icon: Icons.slideshow_outlined, label: 'Create slides'),
    (icon: Icons.language_outlined, label: 'Build website'),
    (icon: Icons.palette_outlined, label: 'Design'),
    (icon: Icons.sports_esports_outlined, label: 'Create games'),
  ];
}
