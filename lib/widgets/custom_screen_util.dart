import 'package:flutter/widgets.dart';

/// A lightweight screen utility for responsive Flutter UIs.
/// Initialize once in your root widget, then use anywhere.
///
/// Usage:
///   ScreenUtil.init(context);
///   double w = 200.w;   // scaled width
///   double h = 100.h;   // scaled height
///   double f = 16.sp;   // scaled font size
class ScreenUtil {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _pixelRatio;

  /// Design canvas size (default: 375×812 — iPhone 14 logical pixels)
  static const double designWidth = 375;
  static const double designHeight = 812;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get pixelRatio => _pixelRatio;

  /// Scale factors
  static double get scaleWidth => _screenWidth / designWidth;
  static double get scaleHeight => _screenHeight / designHeight;

  /// Call this once inside your root widget's build method.
  static void init(BuildContext context) {
    final media = MediaQuery.of(context);
    _screenWidth = media.size.width;
    _screenHeight = media.size.height;
    _pixelRatio = media.devicePixelRatio;
  }

  /// Scaled width
  static double w(double size) => size * scaleWidth;

  /// Scaled height
  static double h(double size) => size * scaleHeight;

  /// Scaled font size (uses the smaller scale to avoid overflow)
  static double sp(double size) => size * (scaleWidth < scaleHeight ? scaleWidth : scaleHeight);

  /// Scaled radius / generic size (same as width scale)
  static double r(double size) => size * scaleWidth;

  /// Responsive value: returns [mobile] below 600px, [tablet] above.
  static T responsive<T>(BuildContext context, {required T mobile, required T tablet}) {
    return _screenWidth >= 600 ? tablet : mobile;
  }
}

// ---------------------------------------------------------------------------
// Extension helpers — lets you write  200.w  instead of  ScreenUtil.w(200)
// ---------------------------------------------------------------------------
extension ScreenUtilNum on num {
  /// Scaled width
  double get w => ScreenUtil.w(toDouble());

  /// Scaled height
  double get h => ScreenUtil.h(toDouble());

  /// Scaled font size
  double get sp => ScreenUtil.sp(toDouble());

  /// Scaled radius / padding
  double get r => ScreenUtil.r(toDouble());
}

// ---------------------------------------------------------------------------
// Example usage (remove in production)
// ---------------------------------------------------------------------------
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);   // ← initialise here
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Container(
//             width: 200.w,
//             height: 100.h,
//             child: Text('Hello', style: TextStyle(fontSize: 16.sp)),
//           ),
//         ),
//       ),
//     );
//   }
// }