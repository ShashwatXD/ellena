import 'package:flutter/material.dart';

import 'chat_drawer.dart';

class ChatShell extends StatelessWidget {
  const ChatShell({super.key, required this.child});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const ChatDrawer(),
      body: child,
    );
  }
}
