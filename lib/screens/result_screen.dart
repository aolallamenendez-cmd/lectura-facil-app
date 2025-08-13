import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/adapter.dart';
import '../services/tts_service.dart';

class ResultScreen extends StatefulWidget {
  final String originalText;
  const ResultScreen({super.key, required this.originalText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String adapted;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    final adapter = context.read<TextAdapter>();
    adapted = adapter.adapt(widget.originalText, advanced: _advanced).adapted;
  }

  void _rebuild() {
    final adapter = context.read<TextAdapter>();
    setState(() {
      adapted = adapter.adapt(widget.originalText, advanced: _advanced).adapted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        actions: [
          Switch(
            value: _advanced,
            onChanged: (v) {
              _advanced = v;
              _rebuild();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Original', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(widget.originalText),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Adaptado', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(_advanced ? '(Avanzado)' : '(Básico)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(adapted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => TTSService.speak(adapted),
              icon: const Icon(Icons.volume_up),
              label: const Text('Escuchar'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => TTSService.stop(),
              icon: const Icon(Icons.stop),
              label: const Text('Parar'),
            ),
          ],
        ),
      ),
    );
  }
}
