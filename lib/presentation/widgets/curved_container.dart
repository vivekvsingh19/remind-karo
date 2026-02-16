import 'package:flutter/material.dart';

/// Custom curved edges clipper
class TCustomCurvedEdges extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstCurve = Offset(0, size.height - 20);
    final lastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(
      firstCurve.dx,
      firstCurve.dy,
      lastCurve.dx,
      lastCurve.dy,
    );

    final secondFirstCurve = Offset(0, size.height - 20);
    final secondLastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    final thirdFirstCurve = Offset(size.width, size.height - 20);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(
      thirdFirstCurve.dx,
      thirdFirstCurve.dy,
      thirdLastCurve.dx,
      thirdLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<dynamic> oldClipper) {
    return true;
  }
}

/// Curved container with clip path design
class CurvedContainer extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final EdgeInsets padding;
  final bool showCurve;

  const CurvedContainer({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.showCurve = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showCurve) {
      return Container(color: backgroundColor, padding: padding, child: child);
    }

    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: Container(color: backgroundColor, padding: padding, child: child),
    );
  }
}

/// Alternative curved container with rounded top corners
class CurvedContainerRounded extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final EdgeInsets padding;
  final bool showCurve;

  const CurvedContainerRounded({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.showCurve = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showCurve) {
      return Container(color: backgroundColor, padding: padding, child: child);
    }

    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: Container(color: backgroundColor, padding: padding, child: child),
    );
  }
}

/// Wave-style curved container
class WaveCurvedContainer extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final double waveHeight;
  final EdgeInsets padding;

  const WaveCurvedContainer({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.waveHeight = 50,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(waveHeight: waveHeight),
      child: Container(color: backgroundColor, padding: padding, child: child),
    );
  }
}

/// Custom clip path for wave design
class _WaveClipper extends CustomClipper<Path> {
  final double waveHeight;

  _WaveClipper({required this.waveHeight});

  @override
  Path getClip(Size size) {
    var path = Path();

    double yOffset = size.height - waveHeight;

    // Start from top-left
    path.lineTo(0, yOffset);

    // Create wave pattern
    path.quadraticBezierTo(
      size.width * 0.25,
      yOffset - waveHeight,
      size.width * 0.5,
      yOffset,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      yOffset + waveHeight,
      size.width,
      yOffset,
    );

    // Line to top-right
    path.lineTo(size.width, 0);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) {
    return oldClipper.waveHeight != waveHeight;
  }
}
