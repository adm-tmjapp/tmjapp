import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/sign_up/presentation/widgets/sign_up_terms_checkbox.dart';

void main() {
  testWidgets('opens terms and privacy independently', (tester) async {
    var termsOpened = false;
    var privacyOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpTermsCheckbox(
            value: true,
            onChanged: (_) {},
            onTermsPressed: () => termsOpened = true,
            onPrivacyPressed: () => privacyOpened = true,
          ),
        ),
      ),
    );

    expect(find.text('Termos de Serviço'), findsOneWidget);
    expect(find.text('Política de Privacidade'), findsOneWidget);

    await tester.tap(find.text('Termos de Serviço'));
    expect(termsOpened, isTrue);
    expect(privacyOpened, isFalse);

    await tester.tap(find.text('Política de Privacidade'));
    expect(privacyOpened, isTrue);
  });
}
