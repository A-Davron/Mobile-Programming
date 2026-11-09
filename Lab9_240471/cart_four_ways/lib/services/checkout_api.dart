class CheckoutException implements Exception {
  const CheckoutException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CheckoutApi {
  Future<String> submit(double total) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (total > 500) throw const CheckoutException('Card declined');
    return 'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}
