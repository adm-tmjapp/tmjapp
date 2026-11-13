import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_finished_sheet.dart';

void main() {
  testWidgets('seleciona a nota ao tocar nas estrelas', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RideFinishedSheet(
            originTitle: 'Origem',
            destinationTitle: 'Destino',
            driverName: 'Motorista TMJ',
            finalPrice: 25,
            paymentMethod: 'Pix',
            onFinish: () {},
          ),
        ),
      ),
    );

    expect(find.text('Avaliação selecionada: 3 de 5 estrelas'), findsNothing);

    await tester.tap(find.byTooltip('3 estrelas'));
    await tester.pump();

    expect(find.text('3 estrelas selecionadas'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Avaliação selecionada: 3 de 5 estrelas'),
      findsOneWidget,
    );
  });

  testWidgets('envia a avaliação selecionada antes de concluir',
      (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var submittedRating = 0;
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RideFinishedSheet(
            originTitle: 'Origem',
            destinationTitle: 'Destino',
            driverName: 'Motorista TMJ',
            finalPrice: 25,
            paymentMethod: 'Pix',
            onSubmitRating: (rating) async => submittedRating = rating,
            onFinish: () => finished = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('4 estrelas'));
    await tester.tap(find.text('CONCLUIR'));
    await tester.pump();

    expect(submittedRating, 4);
    expect(finished, isTrue);
  });
}
