import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final dynamic restaurant;
  final Customer customer;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurant,
    required this.customer,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  List<dynamic> menuItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  // Get restaurant image URL based on restaurant name
  String getRestaurantImage(String name) {
    final imageMap = {
      'Pizza Paradise':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
      'Burger Barn':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
      'Sushi Supreme':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&q=80',
      'Taco Town':
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80',
      'Desi Delights':
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&q=80',
      'Chinese Wok':
          'https://images.unsplash.com/photo-1526318896980-cf78c088247c?w=800&q=80',
      'Pasta Palace':
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80',
      'BBQ Tonight':
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
      'Cafe Delight':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
      'Biryani House':
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&q=80',
    };
    return imageMap[name] ??
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80';
  }

  // Get food image based on item name keywords
  String getMenuItemImage(String itemName) {
    final name = itemName.toLowerCase();

    // Pizza
    if (name.contains('pizza'))
      return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80';

    // Burgers
    if (name.contains('burger'))
      return 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80';

    // Sushi
    if (name.contains('sushi') || name.contains('roll'))
      return 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&q=80';

    // Tacos
    if (name.contains('taco'))
      return 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&q=80';

    // Biryani/Rice dishes
    if (name.contains('biryani') ||
        name.contains('pulao') ||
        name.contains('rice'))
      return 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80';

    // Chinese/Noodles
    if (name.contains('noodle') ||
        name.contains('chow mein') ||
        name.contains('fried rice') ||
        name.contains('manchurian'))
      return 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80';

    // Pasta
    if (name.contains('pasta') ||
        name.contains('spaghetti') ||
        name.contains('penne') ||
        name.contains('alfredo') ||
        name.contains('carbonara') ||
        name.contains('lasagna'))
      return 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80';

    // BBQ/Grilled
    if (name.contains('bbq') ||
        name.contains('grill') ||
        name.contains('tikka') ||
        name.contains('kebab') ||
        name.contains('steak') ||
        name.contains('ribs') ||
        name.contains('boti'))
      return 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=80';

    // Karahi/Curry
    if (name.contains('karahi') ||
        name.contains('curry') ||
        name.contains('handi'))
      return 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=80';

    // Wings/Chicken pieces
    if (name.contains('wing') ||
        name.contains('chicken') && !name.contains('biryani'))
      return 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=400&q=80';

    // Coffee
    if (name.contains('coffee') ||
        name.contains('cappuccino') ||
        name.contains('latte') ||
        name.contains('espresso') ||
        name.contains('mocha'))
      return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80';

    // Desserts/Cakes
    if (name.contains('cake') ||
        name.contains('brownie') ||
        name.contains('dessert') ||
        name.contains('tiramisu') ||
        name.contains('cheesecake'))
      return 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&q=80';

    // Ice cream
    if (name.contains('ice cream') || name.contains('gelato'))
      return 'https://images.unsplash.com/photo-1501443762994-82bd5dace89a?w=400&q=80';

    // Sandwich/Wrap
    if (name.contains('sandwich') || name.contains('wrap'))
      return 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400&q=80';

    // Soup
    if (name.contains('soup'))
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80';

    // Spring rolls/Appetizers
    if (name.contains('roll') ||
        name.contains('samosa') ||
        name.contains('pakora'))
      return 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400&q=80';

    // Juice/Beverages
    if (name.contains('juice') ||
        name.contains('drink') ||
        name.contains('beverage'))
      return 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&q=80';

    // Bread/Naan
    if (name.contains('bread') ||
        name.contains('naan') ||
        name.contains('croissant'))
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80';

    // Salad
    if (name.contains('salad'))
      return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80';

    // Gulab Jamun/Indian sweets
    if (name.contains('gulab') ||
        name.contains('jamun') ||
        name.contains('kheer'))
      return 'https://images.unsplash.com/photo-1606744837616-56c5b6ce6126?w=400&q=80';

    // Fries
    if (name.contains('fries') || name.contains('potato'))
      return 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&q=80';

    // Default food image
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80';
  }

  // Get icon based on category
  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.fastfood;

    switch (categoryName.toLowerCase()) {
      case 'main course':
        return Icons.restaurant_menu;
      case 'fast food':
        return Icons.fastfood;
      case 'desserts':
        return Icons.cake;
      case 'beverages':
        return Icons.local_cafe;
      case 'appetizers':
        return Icons.restaurant;
      default:
        return Icons.fastfood;
    }
  }

  // Get display name for category
  String _getCategoryDisplayName(String? categoryName) {
    if (categoryName == null) return 'Menu';

    switch (categoryName.toLowerCase()) {
      case 'appetizers':
        return 'Starters';
      case 'main course':
        return 'Main Course';
      case 'fast food':
        return 'Main Items';
      case 'desserts':
        return 'Desserts';
      case 'beverages':
        return 'Drinks';
      default:
        return categoryName;
    }
  }

  // Get color based on category
  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return Colors.deepOrange;

    switch (categoryName.toLowerCase()) {
      case 'appetizers':
        return Colors.orange.shade700;
      case 'main course':
        return Colors.red.shade700;
      case 'fast food':
        return Colors.deepOrange;
      case 'desserts':
        return Colors.pink.shade600;
      case 'beverages':
        return Colors.blue.shade700;
      default:
        return Colors.deepOrange;
    }
  }

  Future<void> _fetchMenuItems() async {
    try {
      final data = await ApiService.getMenuItems(
        widget.restaurant['restaurant_id'],
      );
      setState(() {
        menuItems = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading menu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart(dynamic item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      final cartItem = CartItem(
        itemId: item['item_id'],
        itemName: item['item_name'],
        description: item['description'] ?? '',
        price: double.parse(item['price'].toString()),
        restaurantId: widget.restaurant['restaurant_id'],
        restaurantName: widget.restaurant['name'],
      );

      cartProvider.addItem(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['item_name']} added to cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(customer: widget.customer),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _removeFromCart(dynamic item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.decrementQuantity(item['item_id']);
  }

  int _getItemQuantity(int itemId) {
    final cartProvider = Provider.of<CartProvider>(context);
    return cartProvider.getItemQuantity(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Restaurant Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Restaurant Image
                  Image.network(
                    getRestaurantImage(widget.restaurant['name'] ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.deepOrange.shade400,
                              Colors.orange.shade300,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Restaurant name
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.restaurant['name'] ?? 'Restaurant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.restaurant['location'] ?? 'Unknown location',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.restaurant['opening_time']?.toString().substring(0, 5) ?? '00:00'} - ${widget.restaurant['closing_time']?.toString().substring(0, 5) ?? '00:00'}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.restaurant['rating']?.toString() ?? '0.0',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Menu Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),

          // Menu Items with Category Headers
          isLoading
              ? const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
              : menuItems.isEmpty
              ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No menu items available',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = menuItems[index];
                  final quantity = _getItemQuantity(item['item_id']);

                  // Check if we need to show category header
                  final showCategoryHeader =
                      index == 0 ||
                      menuItems[index - 1]['category_name'] !=
                          item['category_name'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header
                      if (showCategoryHeader)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            top: index == 0 ? 8 : 24,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(item['category_name']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(item['category_name']),
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getCategoryDisplayName(item['category_name']),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Menu Item Card
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Item Icon with category color
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    item['category_name'],
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getCategoryIcon(item['category_name']),
                                  color: _getCategoryColor(
                                    item['category_name'],
                                  ),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['item_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['description'] ?? 'No description',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rs. ${item['price']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Add to Cart Button
                              quantity == 0
                                  ? ElevatedButton(
                                    onPressed: () => _addToCart(item),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                  : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          color: Colors.white,
                                          onPressed:
                                              () => _removeFromCart(item),
                                        ),
                                        Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          color: Colors.white,
                                          onPressed: () => _addToCart(item),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }, childCount: menuItems.length),
              ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // View Cart Button
      bottomNavigationBar:
          cartProvider.itemCount > 0
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CartScreen(customer: widget.customer),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Cart (${cartProvider.itemCount} items) • Rs. ${cartProvider.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
