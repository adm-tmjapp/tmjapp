import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_ride_continuation_card.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_confirmation_draft_local_datasource.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const draft = RideRequestArgs(
    userId: 'user-1',
    origin: RouteLocation(
      title: 'Rua de Origem, 10',
      subtitle: 'Recife - PE',
      latitude: -8.01,
      longitude: -34.90,
    ),
    destination: RouteLocation(
      title: 'Rua de Destino, 20',
      subtitle: 'Recife - PE',
      latitude: -8.02,
      longitude: -34.91,
    ),
    routePoints: [
      HomeLocation(latitude: -8.01, longitude: -34.90),
      HomeLocation(latitude: -8.02, longitude: -34.91),
    ],
  );

  test('persists and restores a confirmation draft', () async {
    final dataSource = RideConfirmationDraftLocalDataSource();

    await dataSource.save(draft);
    final restored = await dataSource.load();

    expect(restored?.userId, draft.userId);
    expect(restored?.origin.title, draft.origin.title);
    expect(restored?.destination.title, draft.destination.title);
    expect(restored?.routePoints, hasLength(2));

    await dataSource.clear();
    expect(await dataSource.load(), isNull);
  });

  testWidgets('shows the confirmation continuation card on Dashboard',
      (tester) async {
    var didTap = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeRideContinuationCard(
            draft: draft,
            onTap: () => didTap = true,
          ),
        ),
      ),
    );

    expect(find.text('Continue de onde parou'), findsOneWidget);
    expect(find.text(draft.destination.title), findsOneWidget);
    expect(find.text('CONTINUAR CORRIDA'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR CORRIDA'));
    expect(didTap, isTrue);
  });
}
