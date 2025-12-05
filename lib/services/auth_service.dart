import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/customer.dart';
import 'api_service.dart';

class AuthService {
  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign Up - Create new customer account
  static Future<Customer?> signUp({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);

      final response = await ApiService.post('/auth/signup', {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': hashedPassword,
      });

      if (response != null) {
        return Customer.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Login - Authenticate customer
  static Future<Customer?> login(String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': hashedPassword,
      });

      if (response != null) {
        return Customer.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Get customer by ID (for session management)
  static Future<Customer?> getCustomerById(int customerId) async {
    try {
      final response = await ApiService.get('/customers/$customerId');
      if (response != null) {
        return Customer.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Get customer error: $e');
      return null;
    }
  }

  // Update customer profile
  static Future<bool> updateProfile({
    required int customerId,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await ApiService.put('/customers/$customerId', {
        'name': name,
        'phone': phone,
        'address': address,
      });
      return response != null;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
