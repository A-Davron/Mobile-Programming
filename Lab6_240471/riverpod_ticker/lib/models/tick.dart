/// One price sample for one symbol.
class Tick {
  const Tick({
    required this.symbol,
    required this.price,
    required this.change,
    required this.at,
  });

  final String symbol;
  final double price;
  final double change; // delta vs previous tick
  final DateTime at;

  bool get isUp => change >= 0;
}
