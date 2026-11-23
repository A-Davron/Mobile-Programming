import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

/// The only error type that leaves this file. [message] is a sentence a user
/// can read on screen.
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// How long to wait for an answer. Tests pass a short value.
  final Duration timeout;

  static const _host = 'dummyjson.com';

  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) async {
    final uri = Uri.https(_host, '/products', {'limit': '$limit', 'skip': '$skip'});
    return _parse(await _get(uri), ProductPage.fromJson);
  }

  Future<Product> getProduct(int id) async {
    final uri = Uri.https(_host, '/products/$id');
    return _parse(await _get(uri), Product.fromJson);
  }

  Future<ProductPage> search(String query) async {
    // Uri.https encodes spaces and symbols in the query for us.
    final uri = Uri.https(_host, '/products/search', {'q': query});
    return _parse(await _get(uri), ProductPage.fromJson);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const ApiException('The server is taking too long to answer. Please try again.');
    } on http.ClientException {
      throw const ApiException('No internet connection. Check your network and try again.');
    }

    // Status before body: a 404 also has a JSON body, but it is not a product.
    if (response.statusCode != 200) {
      throw ApiException(_statusMessage(response.statusCode));
    }

    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) return json;
    } on FormatException {
      // Falls through to the error below.
    }
    throw const ApiException('The server sent an answer the app cannot read.');
  }

  T _parse<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    try {
      return fromJson(json);
    } on TypeError {
      throw const ApiException('The server sent data in an unexpected format.');
    }
  }

  String _statusMessage(int code) => switch (code) {
        404 => 'Nothing was found (error 404).',
        >= 500 => 'The server has a problem right now (error $code). Please try again later.',
        _ => 'The server answered with error $code.',
      };
}
