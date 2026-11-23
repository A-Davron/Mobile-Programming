import 'product.dart';

class ProductPage {
  const ProductPage({ required this.products, required this.total, required this.skip, required this.limit });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductPage.fromJson(Map<String, dynamic> json) => ProductPage(
        products: (json['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        skip: json['skip'] as int,
        limit: json['limit'] as int,
      );
}
