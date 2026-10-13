import 'package:flutter_test/flutter_test.dart';

import 'package:iptv_player/core/utils/m3u_parser.dart';

void main() {
  test('parseM3U extrai canais com metadados validos', () {
    const content = '''
#EXTM3U
#EXTINF:-1 tvg-name="Canal 1" tvg-logo="https://img.example/logo1.png" group-title="Nacional",Canal 1
https://example.com/live1.m3u8
#EXTINF:-1 tvg-name="Canal 2" tvg-logo="https://img.example/logo2.png" group-title="Esportes",Canal 2
https://example.com/live2.m3u8
''';

    final channels = parseM3U(content);

    expect(channels, hasLength(2));
    expect(channels.first.name, 'Canal 1');
    expect(channels.first.logo, 'https://img.example/logo1.png');
    expect(channels.first.group, 'Nacional');
    expect(channels.first.url, 'https://example.com/live1.m3u8');
    expect(channels[1].group, 'Esportes');
  });

  test('parseM3U ignora entradas malformadas e conteudo vazio', () {
    const content = '''
#EXTM3U
#EXTINF:-1 tvg-name="Quebrado"
invalid
#EXTINF:-1 group-title="Cinema",Cinema
https://example.com/valid.m3u8
#EXTINF:-1 tvg-name="Outro",Outro
not_a_valid_url
''';

    final channels = parseM3U(content);

    expect(channels, hasLength(1));
    expect(channels.first.name, 'Cinema');
    expect(channels.first.url, 'https://example.com/valid.m3u8');
    expect(parseM3U('   '), isEmpty);
    expect(parseM3U(''), isEmpty);
  });
}
