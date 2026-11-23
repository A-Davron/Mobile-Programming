import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/data/product_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _fixture() =>
    jsonDecode(File('test/fixtures/product.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('getProducts parses the fixture wrapped in a page', () async {
    late Uri requested;
    final api = ProductApi(
      client: MockClient((request) async {
        requested = request.url;
        final page = {'products': [_fixture()], 'total': 1, 'skip': 0, 'limit': 20};
        return http.Response(jsonEncode(page), 200);
      }),
    );

    final page = await api.getProducts();

    expect(page.products, hasLength(1));
    expect(page.products.single.title, 'Essence Mascara Lash Princess');
    expect(page.total, 1);
    expect(requested.path, '/products');
    expect(requested.queryParameters, {'limit': '20', 'skip': '0'});
  });

  test('getProduct throws ApiException on status 404', () async {
    final api = ProductApi(
      client: MockClient((_) async =>
          http.Response('{"message":"Product with id \'0\' not found"}', 404)),
    );

    expect(api.getProduct(0), throwsA(isA<ApiException>()));
  });

  test('search sends the query as q', () async {
    late Uri requested;
    final api = ProductApi(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response('{"products":[],"total":0,"skip":0,"limit":30}', 200);
      }),
    );

    final page = await api.search('red lipstick');

    expect(page.products, isEmpty);
    expect(requested.path, '/products/search');
    expect(requested.queryParameters['q'], 'red lipstick');
  });

  test('lost connection, bad JSON and timeout all become ApiException', () async {
    final offline = ProductApi(
      client: MockClient((_) async => throw http.ClientException('Failed host lookup')),
    );
    final garbage = ProductApi(
      client: MockClient((_) async => http.Response('<html>oops</html>', 200)),
    );
    final slow = ProductApi(
      timeout: const Duration(milliseconds: 10),
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('{}', 200);
      }),
    );

    await expectLater(offline.getProducts(), throwsA(isA<ApiException>()));
    await expectLater(garbage.getProducts(), throwsA(isA<ApiException>()));
    await expectLater(slow.getProducts(), throwsA(isA<ApiException>()));
  });
}
