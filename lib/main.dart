import 'package:check_svg/widgets/custom_screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

// Method 1: Extract and display the embedded base64 image directly
class ExtractBase64ImageWidget extends StatefulWidget {
  final String svgAssetPath; // Path to your SVG in assets folder
  final double? height;
  final double? width;

  const ExtractBase64ImageWidget({
    super.key,
    required this.svgAssetPath, this.height, this.width,
  });

  @override
  _ExtractBase64ImageWidgetState createState() => _ExtractBase64ImageWidgetState();
}

class _ExtractBase64ImageWidgetState extends State<ExtractBase64ImageWidget> {
  Uint8List? imageBytes;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAndExtractImage();
  }

  Future<void> _loadAndExtractImage() async {
    try {
      // Load SVG content from assets
      String svgContent = await DefaultAssetBundle.of(context).loadString(widget.svgAssetPath);

      // Fix the transform matrix issue in kariowatch.svg
      // Replace negative Y translation with 0
      svgContent = svgContent.replaceAll(
        RegExp(r'transform="matrix\(([\d.]+)\s+0\s+0\s+([\d.]+)\s+0\s+-[\d.]+\)"'),
        'transform="matrix(${1} 0 0 ${2} 0 0)"',
      );

      // Extract base64 string from the SVG
      // Pattern to find base64 in xlink:href attribute
      final RegExp regExp = RegExp(
        r'xlink:href="data:image/[^;]+;base64,([^"]+)"',
        multiLine: true,
        dotAll: true,
      );

      final Match? match = regExp.firstMatch(svgContent);

      if (match != null) {
        String base64String = match.group(1)!;

        // Clean the base64 string (remove any whitespace or line breaks)
        base64String = base64String.replaceAll(RegExp(r'\s'), '');

        // Decode to bytes
        final Uint8List bytes = base64Decode(base64String);

        setState(() {
          imageBytes = bytes;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No base64 image found in SVG';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading image: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (imageBytes != null) {
      return Container(
        padding: EdgeInsets.all(2.sp),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
          height: widget.height ?? 65.h,
          width: widget.height ?? 65.w,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text('Error displaying image'),
            );
          },
        ),
      );
    }
    return Center(child: Text('No image to display'));
  }
}


// Main app showing both methods
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SVG with Base64 Image')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExtractBase64ImageWidget(
                svgAssetPath: 'assets/images/kario_img.svg',
                height: 400,
                width: 250,
              ),
          ],),
        )
      ),
    );
  }
}