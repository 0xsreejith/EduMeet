import 'package:flutter/material.dart';

/// Screen size breakpoints helper
class ResponsiveBreakpoints {
  static const double smallMobileMaxWidth = 360;
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double maxContentWidth = 720;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < smallMobileMaxWidth;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileMaxWidth &&
      MediaQuery.sizeOf(context).width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallMobileMaxWidth) return 12;
    if (width < mobileMaxWidth) return 20;
    return 24;
  }
}

/// A responsive wrapper widget that constrains content to a sensible maximum width
/// on tablets/foldables/desktops while expanding naturally on mobile devices.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

