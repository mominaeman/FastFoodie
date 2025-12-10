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
    String? paymentMethod,
    String? specialInstructions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': userId,
          'restaurant_id': restaurantId,
          'total_amount': totalAmount,
          'delivery_address': deliveryAddress,
          'items': items,
          'payment_method': paymentMethod ?? 'COD',
          'special_instructions': specialInstructions,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
        Uri.parse('$baseUrl/customers/$userId/orders'),
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

  // Get order details with items
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/$orderId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      print('Error fetching order details: $e');
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

  // ===========================
  // ADDRESS ENDPOINTS
  // ===========================

  // Get all addresses for a customer
  static Future<List<dynamic>> getCustomerAddresses(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerId/addresses'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      rethrow;
    }
  }

  // Add new address for a customer
  static Future<Map<String, dynamic>> addAddress({
    required int customerId,
    required String label,
    required String addressLine,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/$customerId/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'label': label,
          'address_line': addressLine,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add address');
      }
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    }
  }

  // Update an address
  static Future<Map<String, dynamic>> updateAddress({
    required int addressId,
    required int customerId,
    required String label,
    required String addressLine,
    required bool isDefault,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'label': label,
          'address_line': addressLine,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update address');
      }
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }

  // Delete an address
  static Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set address as default
  static Future<Map<String, dynamic>> setDefaultAddress(int addressId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId/set-default'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to set default address');
      }
    } catch (e) {
      print('Error setting default address: $e');
      rethrow;
    }
  }
}
