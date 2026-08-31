import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_local_datasource.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_remote_datasource.dart';
import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';
import 'package:tmjapp/features/payments/presentation/controllers/payments_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('salva e atualiza cartão usando somente dados seguros', () async {
    final dataSource = PaymentsLocalDataSource();
    const card = PaymentMethodItem(
      id: 'card-1',
      brand: 'visa',
      label: 'Visa •••• 4242',
      subtitle: 'MARIA SILVA',
      last4: '4242',
      holderName: 'MARIA SILVA',
      expiry: '12/30',
      isLocal: true,
    );

    await dataSource.saveCard(card);
    await dataSource.saveCard(const PaymentMethodItem(
      id: 'card-1',
      brand: 'visa',
      label: 'Visa •••• 4242',
      subtitle: 'MARIA SOUZA',
      last4: '4242',
      holderName: 'MARIA SOUZA',
      expiry: '01/31',
      isLocal: true,
    ));

    final cards = await dataSource.getCards();
    expect(cards, hasLength(1));
    expect(cards.single.holderName, 'MARIA SOUZA');
    expect(cards.single.expiry, '01/31');
  });

  test('acumula e restaura o saldo da carteira', () async {
    final dataSource = PaymentsLocalDataSource();
    await dataSource.addBalance(20);
    await dataSource.addBalance(35.50);
    expect(await dataSource.getBalance(), 55.50);
  });

  test('não exibe Pix nem Dinheiro na área de cartões salvos', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode([
            {'status': 'completed', 'payment_method': 'pix'},
            {'status': 'completed', 'payment_method': 'cash'},
            {'status': 'completed', 'payment_method': 'credit_card'},
          ]),
          200,
        ));
    final controller = PaymentsController(
      remoteDataSource: PaymentsRemoteDataSource(
        baseApi: BaseApi(baseUrl: 'https://api.tmj.test/', client: client),
      ),
      localDataSource: PaymentsLocalDataSource(),
    );

    await controller.initialize();

    expect(controller.state.methods, hasLength(1));
    expect(controller.state.methods.single.id, 'credit_card');
    controller.dispose();
  });
}
