import 'package:flutter_test/flutter_test.dart';

import 'package:iptv_player/main.dart';

void main() {
  testWidgets('IPTVPlayerApp renderiza a tela inicial', (tester) async {
    await tester.pumpWidget(const IPTVPlayerApp());

    expect(find.text('IPTV Player - Em desenvolvimento'), findsOneWidget);
  });
}
