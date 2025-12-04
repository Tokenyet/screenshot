import 'package:flutter/material.dart';
import 'dart:async';

import 'package:just_screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Ready';
  CapturedData? _capturedData;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _captureScreen() async {
    try {
      setState(() {
        _status = 'Capturing screen...';
        _capturedData = null;
      });

      final CapturedData? data = await Screenshot.instance.capture(mode: ScreenshotMode.screen, includeCursor: true);

      if (data != null) {
        setState(() {
          _capturedData = data;
          _status = 'Screenshot captured: ${data.width}x${data.height}';
        });
      } else {
        setState(() {
          _status = 'Capture cancelled';
        });
      }
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _status = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _captureRegion() async {
    try {
      setState(() {
        _status = 'Select a region...';
        _capturedData = null;
      });

      final CapturedData? data = await Screenshot.instance.capture(mode: ScreenshotMode.region);

      if (data != null) {
        setState(() {
          _capturedData = data;
          _status = 'Region captured: ${data.width}x${data.height}';
        });
      } else {
        setState(() {
          _status = 'Capture cancelled';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture cancelled')));
        }
      }
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _status = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Screenshot Plugin Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(onPressed: _captureScreen, child: const Text('Capture Screen')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _captureRegion, child: const Text('Capture Region')),
              const SizedBox(height: 20),
              Text(_status),
              const SizedBox(height: 20),
              if (_capturedData != null) ...[
                Text(
                  'Dimensions: ${_capturedData!.width}x${_capturedData!.height}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
                    child: Image.memory(_capturedData!.bytes, fit: BoxFit.contain),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
