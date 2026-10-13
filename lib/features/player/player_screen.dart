import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.url,
    required this.name,
  });

  final String url;
  final String name;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<String>? _errorSubscription;
  Timer? _loadingTimeout;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _playingSubscription = _player.stream.playing.listen((isPlaying) {
      if (isPlaying && mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
        _loadingTimeout?.cancel();
      }
    });
    _errorSubscription = _player.stream.error.listen((message) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
        _loadingTimeout?.cancel();
      }
    });
    unawaited(_openStream());
  }

  Future<void> _openStream() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'A versão web precisa de uma URL de streaming HTTP ou HTTPS. '
            'Este endereço pode exigir um app nativo.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'O canal não iniciou após 15 segundos. Verifique se a URL está '
              'ativa e se o servidor permite reprodução no navegador.';
        });
      }
    });

    try {
      await _player.open(Media(widget.url));
    } catch (error) {
      if (mounted) {
        _loadingTimeout?.cancel();
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      }
    }
  }

  Future<void> _retry() async {
    await _player.stop();
    await _openStream();
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    unawaited(_playingSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Video(controller: _controller),
              if (_isLoading)
                const ColoredBox(
                  color: Colors.black54,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_errorMessage case final message?)
                ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Não foi possível reproduzir este canal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No navegador, o servidor do canal também precisa '
                            'permitir acesso web (CORS) e estar acessível.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
