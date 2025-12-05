import 'package:postgres/postgres.dart';
import '../gcp_config.dart';

class GCPDatabaseService {
  Connection? _connection;

  // Connect to Google Cloud SQL PostgreSQL database
  Future<Connection> connect() async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: GCPConfig.host,
          port: GCPConfig.port,
          database: GCPConfig.database,
          username: GCPConfig.username,
          password: GCPConfig.password,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable, // Change to SslMode.require for production
        ),
      );

      _connection = connection;
      print('✅ Connected to Google Cloud SQL successfully!');
      return connection;
    } catch (e) {
      print('❌ Error connecting to Google Cloud SQL: $e');
      rethrow;
    }
  }

  // Close the connection
  Future<void> close() async {
    await _connection?.close();
    print('Connection closed');
  }

  // Example: Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final conn = _connection ?? await connect();

      final results = await conn.execute(
        'SELECT * FROM restaurants WHERE is_active = true ORDER BY rating DESC',
      );

      return results.map((row) {
        return {
          'id': row[0],
          'name': row[1],
          'address': row[2],
          'phone': row[3],
          'rating': row[4],
          'is_active': row[5],
          'created_at': row[6],
        };
      }).toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  // Example: Get menu items for a restaurant
  Future<List<Map<String, dynamic>>> getMenuItems(int restaurantId) async {
    try {
      final conn = _connection ?? await connect();

      final results = await conn.execute(
        Sql.named('''
          SELECT * FROM menu_items 
          WHERE restaurant_id = @restaurantId AND is_available = true
          ORDER BY category, name
        '''),
        parameters: {'restaurantId': restaurantId},
      );

      return results.map((row) {
        return {
          'id': row[0],
          'restaurant_id': row[1],
          'name': row[2],
          'description': row[3],
          'price': row[4],
          'category': row[5],
          'is_available': row[6],
          'image_url': row[7],
          'created_at': row[8],
        };
      }).toList();
    } catch (e) {
      print('Error fetching menu items: $e');
      return [];
    }
  }

  // Example: Create a new order
  Future<int?> createOrder({
    required int userId,
    required int restaurantId,
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    try {
      final conn = _connection ?? await connect();

      final results = await conn.execute(
        Sql.named('''
          INSERT INTO orders (user_id, restaurant_id, total_amount, delivery_address, status)
          VALUES (@userId, @restaurantId, @totalAmount, @deliveryAddress, 'pending')
          RETURNING id
        '''),
        parameters: {
          'userId': userId,
          'restaurantId': restaurantId,
          'totalAmount': totalAmount,
          'deliveryAddress': deliveryAddress,
        },
      );

      if (results.isNotEmpty) {
        final orderId = results.first[0] as int;
        print('✅ Order created with ID: $orderId');
        return orderId;
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Example: Add items to an order
  Future<bool> addOrderItems({
    required int orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final conn = _connection ?? await connect();

      for (var item in items) {
        await conn.execute(
          Sql.named('''
            INSERT INTO order_items (order_id, menu_item_id, quantity, price)
            VALUES (@orderId, @menuItemId, @quantity, @price)
          '''),
          parameters: {
            'orderId': orderId,
            'menuItemId': item['menu_item_id'],
            'quantity': item['quantity'],
            'price': item['price'],
          },
        );
      }

      print('✅ Order items added successfully');
      return true;
    } catch (e) {
      print('Error adding order items: $e');
      return false;
    }
  }

  // Example: Get user's orders
  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    try {
      final conn = _connection ?? await connect();

      final results = await conn.execute(
        Sql.named('''
          SELECT 
            o.*,
            r.name as restaurant_name,
            r.address as restaurant_address
          FROM orders o
          JOIN restaurants r ON o.restaurant_id = r.id
          WHERE o.user_id = @userId
          ORDER BY o.created_at DESC
        '''),
        parameters: {'userId': userId},
      );

      return results.map((row) {
        return {
          'id': row[0],
          'user_id': row[1],
          'restaurant_id': row[2],
          'total_amount': row[3],
          'status': row[4],
          'delivery_address': row[5],
          'created_at': row[6],
          'updated_at': row[7],
          'restaurant_name': row[8],
          'restaurant_address': row[9],
        };
      }).toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  // Example: Update order status
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final conn = _connection ?? await connect();

      await conn.execute(
        Sql.named('''
          UPDATE orders 
          SET status = @status, updated_at = CURRENT_TIMESTAMP
          WHERE id = @orderId
        '''),
        parameters: {'orderId': orderId, 'status': status},
      );

      print('✅ Order status updated to: $status');
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Example: Search restaurants
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      final conn = _connection ?? await connect();

      final results = await conn.execute(
        Sql.named('''
          SELECT * FROM restaurants 
          WHERE is_active = true 
          AND (name ILIKE @query OR address ILIKE @query)
          ORDER BY rating DESC
        '''),
        parameters: {'query': '%$query%'},
      );

      return results.map((row) {
        return {
          'id': row[0],
          'name': row[1],
          'address': row[2],
          'phone': row[3],
          'rating': row[4],
          'is_active': row[5],
          'created_at': row[6],
        };
      }).toList();
    } catch (e) {
      print('Error searching restaurants: $e');
      return [];
    }
  }

  // Health check - test database connection
  Future<bool> healthCheck() async {
    try {
      final conn = _connection ?? await connect();
      final results = await conn.execute('SELECT 1');
      return results.isNotEmpty;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
