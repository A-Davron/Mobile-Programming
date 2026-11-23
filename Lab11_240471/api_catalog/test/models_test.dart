import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/models/product.dart';
import 'package:api_catalog/models/product_page.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture() =>
    jsonDecode(File('test/fixtures/product.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('Product.fromJson parses the saved /products/1 response', () {
    final product = Product.fromJson(_fixture());

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, isA<double>());
    expect(product.price, 9.99);
    expect(product.brand, 'Essence');
    expect(product.tags, containsAll(['beauty', 'mascara']));
    expect(product.dimensions.width, 15.14);
    expect(product.reviews, hasLength(3));
    expect(product.reviews.first.reviewerName, 'Eleanor Collins');
    expect(product.reviews.first.date, DateTime.utc(2025, 4, 30, 9, 41, 2, 53));
  });

  test('missing brand gives null and missing tags give an empty list', () {
    final product = Product.fromJson({
      'id': 7,
      'title': 'Hello from Davron :)',
      'price': 10,
      'rating': 4,
      'thumbnail': 'https://newuzbekistan.hero.study/',
      'dimensions': {'width': 1, 'height': 2.5, 'depth': 3},
      'reviews': <dynamic>[],
    });

    expect(product.brand, isNull);
    expect(product.tags, isEmpty);
    expect(product.price, 10.0);
    expect(product.price, isA<double>());
    expect(product.dimensions.width, 1.0);
  });

  test('ProductPage.fromJson reuses Product.fromJson for every item', () {
    final page = ProductPage.fromJson({
      'products': [_fixture(), _fixture()],
      'total': 194,
      'skip': 0,
      'limit': 2,
    });

    expect(page.products, hasLength(2));
    expect(page.products.first.title, 'Essence Mascara Lash Princess');
    expect(page.total, 194);
    expect(page.skip, 0);
    expect(page.limit, 2);
  });
}
