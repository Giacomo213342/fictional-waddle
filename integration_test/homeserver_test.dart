import 'package:flutter_test/flutter_test.dart';

import 'package:polycule/l10n/generated/app_localizations_en.dart';
import 'package:polycule/src/polycule.dart';

void main() {
  testWidgets('Welcome screen', (WidgetTester tester) async {
    final l10n = AppLocalizationsEn();
    await tester.pumpWidget(const PolyculeClient());

    await tester.pumpAndSettle();

    expect(find.text(l10n.homeserverHeadline), findsOneWidget);
  });
}
