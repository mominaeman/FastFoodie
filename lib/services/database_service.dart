import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';
import 'gcp_database_service.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final GCPDatabaseService _directService = GCPDatabaseService();

  // Automatically choose between direct connection (mobile/desktop) or API (web)
  bool get isWeb => kIsWeb;

  // Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    if (isWeb) {
      // Use HTTP API for web
      final data = await ApiService.getRestaurants();
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      // Use direct connection for mobile/desktop
      return await _directService.getRestaurants();
    }
  }

  // Get menu items for a restaurant
  Future<List<Map<String, dynamic>>> getMenuItems(int restaurantId) async {
    if (isWeb) {
      final data = await ApiService.getMenuItems(restaurantId);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return await _directService.getMenuItems(restaurantId);
    }
  }

  // Create a new order
  Future<int?> createOrder({
    required int userId,
    required int restaurantId,
    required double totalAmount,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    if (isWeb) {
      final result = await ApiService.createOrder(
        userId: userId,
        restaurantId: restaurantId,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        items: items,
      );
      return result['orderId'] as int?;
    } else {
      return await _directService.createOrder(
        userId: userId,
        restaurantId: restaurantId,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
      );
    }
  }

  // Get user's orders
  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    if (isWeb) {
      final data = await ApiService.getUserOrders(userId);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return await _directService.getUserOrders(userId);
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(int orderId, String status) async {
    if (isWeb) {
      await ApiService.updateOrderStatus(orderId, status);
      return true;
    } else {
      return await _directService.updateOrderStatus(orderId, status);
    }
  }

  // Search restaurants
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    if (isWeb) {
      final data = await ApiService.searchRestaurants(query);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return await _directService.searchRestaurants(query);
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    if (isWeb) {
      return await ApiService.healthCheck();
    } else {
      return await _directService.healthCheck();
    }
  }

  // Connect (only for direct connection)
  Future<void> connect() async {
    if (!isWeb) {
      await _directService.connect();
    }
  }

  // Close connection (only for direct connection)
  Future<void> close() async {
    if (!isWeb) {
      await _directService.close();
    }
  }
}
