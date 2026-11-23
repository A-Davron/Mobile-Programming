// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products/1'));
  print(response.statusCode); // 200
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  print(json['title']); // Essence Mascara Lash Princess
  print(json['dimensions'].runtimeType); // a Map: a nested object
}
