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

  const ExtractBase64ImageWidget({
    super.key,
    required this.svgAssetPath,
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
      final String svgContent = await DefaultAssetBundle.of(context).loadString(widget.svgAssetPath);

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
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (imageBytes != null) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
          height: 100,
          width: 100,
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

// Method 2: Try to render the SVG directly (may not work with embedded images)
class DirectSvgWidget extends StatelessWidget {
  final String svgAssetPath;

  const DirectSvgWidget({
    super.key,
    required this.svgAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SvgPicture.asset(
        svgAssetPath,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
          padding: const EdgeInsets.all(30.0),
          child: const CircularProgressIndicator(),
        ),
        // This will show if the SVG fails to render
        // (which is likely with embedded base64 images)
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'SVG contains embedded image.\nUsing fallback method...',
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Main app showing both methods
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('SVG with Base64 Image')),
        body: Column(
          children: [
            ExtractBase64ImageWidget(
              svgAssetPath: 'assets/images/logo.svg',
            ),
        ],)
      ),
    );
  }
}