import 'package:flutter/foundation.dart';

import '../models/classification.dart';

/// Every classification of this session, newest first. Lives in memory only:
/// it is created once in main and cleared when the app closes.
class SessionHistory extends ChangeNotifier {
  final List<Classification> _items = [];

  List<Classification> get items => List.unmodifiable(_items);

  Classification? get latest => _items.isEmpty ? null : _items.first;

  bool get isEmpty => _items.isEmpty;

  void add(Classification entry) {
    _items.insert(0, entry);
    notifyListeners();
  }
}
