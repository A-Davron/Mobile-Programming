import 'package:flutter_riverpod/flutter_riverpod.dart ';
import '../models/cart.dart';
class CartNotifier extends Notifier<List<CartLine>> {
@override
List<CartLine> build() => const []; 
void add(Product p) => state = state.withProduct(p); 
void remove(String id) => state = state.without(id);
// 1. initial state, re-run on invalidate
// 2. assignment notifies listeners
}
final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);