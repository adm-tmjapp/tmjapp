import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/core/config/app_environment.dart';
import 'package:tmjapp/features/forgot_password/presentation/pages/reset_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput:
          'API_BASE_URL=https://api.example.com/\nGOOGLE_PLACES_API_KEY=test',
    );
    AppConfig.initialize(AppEnvironment.dev);
  });

  testWidgets('botão voltar leva para a tela de login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: const ResetPasswordPage(email: 'passageiro@tmjapp.com'),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.signIn) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Tela de login')),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );

    expect(find.text('Redefinir senha'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Tela de login'), findsOneWidget);
    expect(find.text('Redefinir senha'), findsNothing);
  });
}
