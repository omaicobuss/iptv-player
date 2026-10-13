import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iptv_player/features/playlist/presentation/playlist_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists imported channels and restores them in a new controller',
      () async {
    final firstController = PlaylistController();
    await firstController.initialized;

    await firstController.loadFromContent('''
#EXTM3U
#EXTINF:-1 tvg-name="Canal Real" tvg-logo="https://tv.example/logo.png" group-title="Notícias",Canal Real
https://tv.example/live.m3u8
''');

    expect(firstController.state.channels, hasLength(1));
    expect(firstController.state.channels.single.name, 'Canal Real');
    final importedChannel = firstController.state.channels.single;
    firstController.dispose();

    final restoredController = PlaylistController();
    await restoredController.initialized;

    expect(restoredController.state.channels, hasLength(1));
    expect(restoredController.state.channels.single, importedChannel);
    restoredController.dispose();
  });

  test('does not replace saved playlist when imported content has no channels',
      () async {
    final controller = PlaylistController();
    await controller.initialized;
    await controller.loadFromContent('''
#EXTM3U
#EXTINF:-1,Canal Real
https://tv.example/live.m3u8
''');

    await controller.loadFromContent('#EXTM3U\nconteúdo sem canais');

    expect(controller.state.channels, hasLength(1));
    expect(controller.state.hasError, isTrue);

    final restoredController = PlaylistController();
    await restoredController.initialized;
    expect(restoredController.state.channels, hasLength(1));
    expect(restoredController.state.channels.single.name, 'Canal Real');

    controller.dispose();
    restoredController.dispose();
  });
}
