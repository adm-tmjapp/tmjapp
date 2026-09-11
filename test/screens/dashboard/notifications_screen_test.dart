import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/screens/dashboard/notifications_screen.dart';

void main() {
  testWidgets('marks every notification as read', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotificationScreen()),
    );

    expect(
      find.byKey(const Key('unread-notification-indicator')),
      findsWidgets,
    );

    await tester.tap(find.byKey(const Key('mark-all-notifications-read')));
    await tester.pump();

    expect(
      find.byKey(const Key('unread-notification-indicator')),
      findsNothing,
    );
    expect(
      find.text('Todas as notificações foram marcadas como lidas.'),
      findsOneWidget,
    );

    final button = tester.widget<TextButton>(
      find.byKey(const Key('mark-all-notifications-read')),
    );
    expect(button.onPressed, isNull);
  });
}
