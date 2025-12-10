import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  int? get restaurantId => _items.isEmpty ? null : _items.first.restaurantId;

  String? get restaurantName =>
      _items.isEmpty ? null : _items.first.restaurantName;

  void addItem(CartItem newItem) {
    // Check if cart has items from different restaurant
    if (_items.isNotEmpty &&
        _items.first.restaurantId != newItem.restaurantId) {
      throw Exception(
        'You can only order from one restaurant at a time. Clear your cart first.',
      );
    }

    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.itemId == newItem.itemId,
    );

    if (existingIndex >= 0) {
      // Item exists, increase quantity
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      // Add new item
      _items.add(newItem);
    }

    notifyListeners();
  }

  void removeItem(int itemId) {
    _items.removeWhere((item) => item.itemId == itemId);
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void incrementQuantity(int itemId) {
    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int itemId) {
    final index = _items.indexWhere((item) => item.itemId == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        removeItem(itemId);
      }
      notifyListeners();
    }
  }

  int getItemQuantity(int itemId) {
    final item = _items.firstWhere(
      (item) => item.itemId == itemId,
      orElse:
          () => CartItem(
            itemId: 0,
            itemName: '',
            description: '',
            price: 0,
            restaurantId: 0,
            restaurantName: '',
            quantity: 0,
          ),
    );
    return item.quantity;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> getOrderItems() {
    return _items
        .map(
          (item) => {
            'item_id': item.itemId,
            'quantity': item.quantity,
            'price': item.price,
          },
        )
        .toList();
  }
}
