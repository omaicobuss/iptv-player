import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iptv_player/main.dart';

void main() {
  testWidgets('IPTVPlayerApp renderiza a tela de canais', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const ProviderScope(
        child: IPTVPlayerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Canais'), findsOneWidget);
    expect(
      find.text('Nenhuma playlist salva. Importe uma lista para começar.'),
      findsOneWidget,
    );
    expect(find.text('Importar'), findsOneWidget);
  });
}
