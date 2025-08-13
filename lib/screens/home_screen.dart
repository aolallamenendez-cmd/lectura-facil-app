import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _busy = false;
  final _picker = ImagePicker();

  Future<void> _scanFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    await _process(File(image.path));
  }

  Future<void> _importFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _process(File(image.path));
  }

  Future<void> _process(File file) async {
    setState(() => _busy = true);
    try {
      final text = await OCRService.recognizeTextFromImage(file);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultScreen(originalText: text),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error OCR: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adapta textos a lectura fácil')),
      body: Center(
        child: _busy
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 96),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _scanFromCamera,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Escanear texto'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _importFromGallery,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Importar imagen'),
                  ),
                ],
              ),
      ),
    );
  }
}
