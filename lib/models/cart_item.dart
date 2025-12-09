class CartItem {
  final int itemId;
  final String itemName;
  final String description;
  final double price;
  final int restaurantId;
  final String restaurantName;
  int quantity;

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.price,
    required this.restaurantId,
    required this.restaurantName,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'description': description,
      'price': price,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item_id'],
      itemName: json['item_name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  CartItem copyWith({
    int? itemId,
    String? itemName,
    String? description,
    double? price,
    int? restaurantId,
    String? restaurantName,
    int? quantity,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      price: price ?? this.price,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      quantity: quantity ?? this.quantity,
    );
  }
}
