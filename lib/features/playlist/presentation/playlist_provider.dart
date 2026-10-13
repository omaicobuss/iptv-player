import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/channel.dart';
import '../../../core/utils/m3u_parser.dart';

const _playlistStorageKey = 'saved_playlist_channels';

class PlaylistState {
  const PlaylistState({
    this.channels = const <Channel>[],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<Channel> channels;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}

class PlaylistController extends StateNotifier<PlaylistState> {
  PlaylistController({
    Future<SharedPreferences> Function()? preferencesFactory,
  })  : _preferencesFactory =
            preferencesFactory ?? SharedPreferences.getInstance,
        super(const PlaylistState()) {
    _initialized = _restoreSavedPlaylist();
  }

  final Future<SharedPreferences> Function() _preferencesFactory;
  late final Future<void> _initialized;

  Future<void> get initialized => _initialized;

  Future<void> loadFromContent(String content) async {
    state = PlaylistState(channels: state.channels);

    try {
      final parsedChannels = parseM3U(content);
      if (parsedChannels.isEmpty) {
        state = PlaylistState(
          channels: state.channels,
          errorMessage: 'Nenhum canal foi encontrado na playlist.',
        );
        return;
      }

      final preferences = await _preferencesFactory();
      final saved = await preferences.setString(
        _playlistStorageKey,
        jsonEncode(parsedChannels.map(_channelToJson).toList()),
      );
      if (!saved) {
        throw StateError(
          'Não foi possível salvar a playlist neste dispositivo.',
        );
      }

      state = PlaylistState(channels: parsedChannels);
    } catch (error) {
      state = PlaylistState(
        channels: state.channels,
        errorMessage: 'Não foi possível salvar a playlist: $error',
      );
    }
  }

  Future<void> loadFromUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      state = PlaylistState(
        channels: state.channels,
        errorMessage: 'Informe uma URL válida.',
      );
      return;
    }

    state = PlaylistState(channels: state.channels);

    try {
      final response = await Dio().get<String>(
        trimmedUrl,
        options: Options(responseType: ResponseType.plain),
      );

      final content = response.data ?? '';
      await loadFromContent(content);
    } catch (error) {
      state = PlaylistState(
        channels: state.channels,
        errorMessage:
            'Não foi possível carregar a playlist pela URL informada: $error',
      );
    }
  }

  Future<void> _restoreSavedPlaylist() async {
    try {
      final preferences = await _preferencesFactory();
      final serializedChannels = preferences.getString(_playlistStorageKey);
      if (serializedChannels == null) {
        state = const PlaylistState(isLoading: false);
        return;
      }

      final decoded = jsonDecode(serializedChannels);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Formato de playlist salvo inválido.');
      }
      final channels = decoded.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Canal salvo inválido.');
        }
        return _channelFromJson(entry);
      }).toList();
      state = PlaylistState(channels: channels, isLoading: false);
    } catch (error) {
      state = PlaylistState(
        isLoading: false,
        errorMessage: 'Não foi possível restaurar a playlist salva: $error',
      );
    }
  }

  Map<String, String> _channelToJson(Channel channel) => <String, String>{
        'name': channel.name,
        'logo': channel.logo,
        'group': channel.group,
        'url': channel.url,
      };

  Channel _channelFromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final logo = json['logo'];
    final group = json['group'];
    final url = json['url'];
    if (name is! String ||
        logo is! String ||
        group is! String ||
        url is! String) {
      throw const FormatException('Metadados do canal salvo inválidos.');
    }
    return Channel(name: name, logo: logo, group: group, url: url);
  }
}

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, PlaylistState>((ref) {
  return PlaylistController();
});
