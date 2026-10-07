import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('tokeniza cartão e retorna apenas dados seguros do ASAAS', () async {
    Map<String, dynamic>? requestBody;
    final client = MockClient((request) async {
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
          jsonEncode({
            'id': 'method-1',
            'type': 'card',
            'brand': 'visa',
            'last4': '4242',
            'holderName': 'MARIA SILVA',
          }),
          201);
    });
    final dataSource = PaymentsRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/', client: client),
    );

    final card = await dataSource.tokenizeCard(
      holderName: 'MARIA SILVA',
      number: '4111111111111111',
      expiryMonth: '12',
      expiryYear: '2030',
      ccv: '123',
    );

    expect(requestBody?['number'], '4111111111111111');
    expect(requestBody?['ccv'], '123');
    expect(card.id, 'method-1');
    expect(card.last4, '4242');
    expect(card.label, 'Visa •••• 4242');
  });

  test('lista somente cartões ativos retornados pelo ASAAS', () async {
    final client = MockClient((_) async => http.Response(
        jsonEncode({
          'methods': [
            {
              'id': 'active',
              'type': 'card',
              'brand': 'mastercard',
              'last4': '5555',
              'status': 'ACTIVE'
            },
            {
              'id': 'inactive',
              'type': 'card',
              'brand': 'visa',
              'last4': '1111',
              'status': 'INACTIVE'
            },
            {'id': 'pix', 'type': 'pix', 'status': 'ACTIVE'},
          ],
        }),
        200));
    final dataSource = PaymentsRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/', client: client),
    );

    final cards = await dataSource.fetchSavedCards();

    expect(cards, hasLength(1));
    expect(cards.single.id, 'active');
    expect(cards.single.last4, '5555');
  });
}
