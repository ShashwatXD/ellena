import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import '../theme/app_motion.dart';
import 'chat_drawer.dart';

class ChatShell extends StatelessWidget {
  const ChatShell({super.key, required this.child});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 24,
      drawer: Drawer(
        width: AppBreakpoints.drawerWidth(context),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.96, end: 1),
          duration: AppMotion.of(context, AppMotion.drawer),
          curve: AppMotion.standard,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset((1 - value) * -12, 0),
                child: child,
              ),
            );
          },
          child: const ChatDrawer(),
        ),
      ),
      body: child,
    );
  }
}
