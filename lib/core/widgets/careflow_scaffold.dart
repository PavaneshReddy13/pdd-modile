import 'package:flutter/material.dart';
import 'careflow_neon_background.dart';

class CareFlowScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool useAnimatedBackground;
  final bool safeArea;
  final bool resizeToAvoidBottomInset;
  final Widget? floatingActionButton;

  const CareFlowScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.useAnimatedBackground = false,
    this.safeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = safeArea ? SafeArea(child: body) : body;

    if (useAnimatedBackground) {
      content = CareFlowNeonBackground(
        showGrid: true,
        showOrb: true,
        child: content,
      );
    } else {
      content = Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: content,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: useAnimatedBackground,
      backgroundColor: useAnimatedBackground ? Colors.transparent : null,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
    );
  }
}
