import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'playlist_provider.dart';

class ImportPlaylistScreen extends ConsumerStatefulWidget {
  const ImportPlaylistScreen({super.key});

  @override
  ConsumerState<ImportPlaylistScreen> createState() =>
      _ImportPlaylistScreenState();
}

class _ImportPlaylistScreenState extends ConsumerState<ImportPlaylistScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadFromSelectedFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['m3u', 'm3u8', 'txt'],
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final file = picked.files.first;
    if (file.bytes == null) {
      return;
    }

    final content = utf8.decode(file.bytes!);
    await ref
        .read(playlistControllerProvider.notifier)
        .loadFromContent(content);
    if (mounted && !ref.read(playlistControllerProvider).hasError) {
      context.pop();
    }
  }

  Future<void> _loadFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      return;
    }

    await ref.read(playlistControllerProvider.notifier).loadFromUrl(url);
    if (mounted && !ref.read(playlistControllerProvider).hasError) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar playlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL da playlist',
                hintText: 'https://exemplo.com/playlist.m3u',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.isLoading ? null : _loadFromUrl,
              icon: const Icon(Icons.link_rounded),
              label: const Text('Carregar pela URL'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: state.isLoading ? null : _loadFromSelectedFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Selecionar arquivo local'),
            ),
            const SizedBox(height: 20),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
