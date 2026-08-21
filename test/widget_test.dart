import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gfghub/main.dart';

void main() {
  testWidgets('SocietyOS smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SocietyOS(),
      ),
    );

    // Verify that the app starts at the login screen (which has 'SocietyOS' text)
    expect(find.text('SocietyOS'), findsOneWidget);
  });
}
