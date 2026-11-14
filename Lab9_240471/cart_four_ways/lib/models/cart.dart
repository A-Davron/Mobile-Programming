class Product {
  const Product({required this.id, required this.name, required this.price});
  final String id;
  final String name;
  final double price;
}

const catalog = [
  Product(id: 'p1', name: 'Keyboard', price: 49),
  Product(id: 'p2', name: 'Mouse', price: 25),
  Product(id: 'p3', name: 'Monitor', price: 199),
];

class CartLine {
  const CartLine({required this.product, required this.qty});
  final Product product;
  final int qty;

  double get subtotal => product.price * qty;

  CartLine copyWith({int? qty}) =>
      CartLine(product: product, qty: qty ?? this.qty);

  /// T2 (Riverpod): `CartState ==` compares lines element-wise, so a line needs
  /// value equality too. Products come from the const [catalog], so comparing
  /// `product.id` is enough.
  @override
  bool operator ==(Object other) =>
      other is CartLine && other.product.id == product.id && other.qty == qty;

  @override
  int get hashCode => Object.hash(product.id, qty);
}

/// Pure, style-independent cart logic. Every state holder calls these.
extension CartLines on List<CartLine> {
  List<CartLine> withProduct(Product p) {
    final i = indexWhere((l) => l.product.id == p.id);
    if (i == -1) return [...this, CartLine(product: p, qty: 1)];
    return [
      for (final l in this)
        l.product.id == p.id ? l.copyWith(qty: l.qty + 1) : l,
    ];
  }

  List<CartLine> without(String productId) => [
    for (final l in this)
      if (l.product.id != productId) l,
  ];

  /// T1: pure quantity change. A `delta` that would drop the line to 0
  /// removes it, so `-` at `qty == 1` is the same as a delete.
  List<CartLine> changeQty(String productId, int delta) {
    final i = indexWhere((l) => l.product.id == productId);
    if (i == -1) return this;
    final next = this[i].qty + delta;
    if (next <= 0) return without(productId);
    return [
      for (final l in this)
        l.product.id == productId ? l.copyWith(qty: next) : l,
    ];
  }

  double get subtotal => fold(0, (s, l) => s + l.subtotal);

  int get itemCount => fold(0, (s, l) => s + l.qty);
}

/// T4: the four phases a checkout goes through, in every style.
enum CheckoutStatus { idle, submitting, success, failure }

/// Sentinel so `copyWith` can tell "leave it alone" from "set it to null".
const Object _unset = Object();

/// T2-T4: the whole cart state, immutable, style-independent.
class CartState {
  const CartState({
    this.lines = const [],
    this.coupon,
    this.couponError,
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.checkoutError,
    this.canUndo = false,
  });

  final List<CartLine> lines;
  final String? coupon;
  final String? couponError;
  final CheckoutStatus status;
  final String? orderId;
  final String? checkoutError;

  /// T5 (Cubit/Bloc): a getter on the cubit is not observable by `BlocBuilder`,
  /// so whether undo is possible has to be part of the state itself. The
  /// `setState` and Riverpod pages keep their own history and leave this false.
  final bool canUndo;

  /// T3: derived values are getters, never stored fields.
  int get itemCount => lines.itemCount;
  double get subtotal => lines.subtotal;
  double get discount => coupon == kCouponCode ? subtotal * 0.10 : 0;
  double get total => subtotal - discount;

  /// T2 (Riverpod): without this, every `copyWith` produces a new instance that
  /// is `!=` the old one, so assigning an unchanged value still notifies.
  @override
  bool operator ==(Object other) =>
      other is CartState &&
      _sameLines(other.lines, lines) &&
      other.coupon == coupon &&
      other.couponError == couponError &&
      other.status == status &&
      other.orderId == orderId &&
      other.checkoutError == checkoutError &&
      other.canUndo == canUndo;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(lines),
    coupon,
    couponError,
    status,
    orderId,
    checkoutError,
    canUndo,
  );

  static bool _sameLines(List<CartLine> a, List<CartLine> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  CartState copyWith({
    List<CartLine>? lines,
    Object? coupon = _unset,
    Object? couponError = _unset,
    CheckoutStatus? status,
    Object? orderId = _unset,
    Object? checkoutError = _unset,
    bool? canUndo,
  }) => CartState(
    lines: lines ?? this.lines,
    coupon: identical(coupon, _unset) ? this.coupon : coupon as String?,
    couponError: identical(couponError, _unset)
        ? this.couponError
        : couponError as String?,
    status: status ?? this.status,
    orderId: identical(orderId, _unset) ? this.orderId : orderId as String?,
    checkoutError: identical(checkoutError, _unset)
        ? this.checkoutError
        : checkoutError as String?,
    canUndo: canUndo ?? this.canUndo,
  );
}

/// The only coupon the catalogue accepts: 10 % off.
const kCouponCode = 'SAVE10';

/// T3: the four derived values bundled into one comparable value, so a
/// selector (Riverpod `select`, `BlocSelector`) can compare them in one go.
class CartTotals {
  const CartTotals({
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory CartTotals.of(CartState s) => CartTotals(
    itemCount: s.itemCount,
    subtotal: s.subtotal,
    discount: s.discount,
    total: s.total,
  );

  final int itemCount;
  final double subtotal;
  final double discount;
  final double total;

  @override
  bool operator ==(Object other) =>
      other is CartTotals &&
      other.itemCount == itemCount &&
      other.subtotal == subtotal &&
      other.discount == discount &&
      other.total == total;

  @override
  int get hashCode => Object.hash(itemCount, subtotal, discount, total);
}
