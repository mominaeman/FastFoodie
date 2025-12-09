import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your deployed API URL when ready
  // For local testing: 'http://localhost:3000/api'
  // For production: 'https://your-app.run.app/api'
  static const String baseUrl = 'http://localhost:3000/api';

  // Generic GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('GET request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('GET error: $e');
      rethrow;
    }
  }

  // Generic POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // Try to parse error message from backend
        String errorMessage = 'Request failed';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Status code: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('POST error: $e');
      rethrow;
    }
  }

  // Generic PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('PUT request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('PUT error: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<bool> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('DELETE error: $e');
      return false;
    }
  }

  // Get all restaurants
  static Future<List<dynamic>> getRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      rethrow;
    }
  }

  // Get menu items for a restaurant
  static Future<List<dynamic>> getMenuItems(int restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/$restaurantId/menu'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      rethrow;
    }
  }

  // Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int restaurantId,
    required double totalAmount,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'restaurant_id': restaurantId,
          'total_amount': totalAmount,
          'delivery_address': deliveryAddress,
          'items': items,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get user's orders
  static Future<List<dynamic>> getUserOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/orders'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  // Update order status
  static Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Search restaurants
  static Future<List<dynamic>> searchRestaurants(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/search/${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search restaurants');
      }
    } catch (e) {
      print('Error searching restaurants: $e');
      rethrow;
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
