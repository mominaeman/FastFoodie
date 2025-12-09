import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  final Customer customer;

  const RestaurantsScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  List<dynamic> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final data = await ApiService.getRestaurants();
      setState(() {
        restaurants = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading restaurants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : restaurants.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No restaurants available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchRestaurants,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Welcome, ${widget.customer.name.split(' ')[0]}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to order today?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Popular Restaurants',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...restaurants.map((restaurant) {
                      return RestaurantCard(
                        restaurant: restaurant,
                        customer: widget.customer,
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final dynamic restaurant;
  final Customer customer;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.customer,
  }) : super(key: key);

  // Get image URL based on restaurant name
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RestaurantDetailScreen(
                    restaurant: restaurant,
                    customer: customer,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        getRestaurantImage(restaurant['name'] ?? ''),
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Fallback to gradient if image fails
                      },
                    ),
                  ),
                ),
                // Dark overlay for better text readability
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Restaurant name badge on image
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurant['rating']?.toString() ?? '0.0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant['location'] ?? 'Unknown location',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant['opening_time']?.toString().substring(0, 5) ?? '00:00'} - ${restaurant['closing_time']?.toString().substring(0, 5) ?? '00:00'}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
