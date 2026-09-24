import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Text(
          AppConstants.appName,
          style: textTheme.headlineMedium,
        ),
      ),
    );
  }
}
