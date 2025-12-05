import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/database_service.dart';

class GCPTestScreen extends StatefulWidget {
  const GCPTestScreen({super.key});

  @override
  State<GCPTestScreen> createState() => _GCPTestScreenState();
}

class _GCPTestScreenState extends State<GCPTestScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _status = 'Not connected';
  bool _isLoading = false;
  List<Map<String, dynamic>> _restaurants = [];

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Connecting...';
    });

    try {
      await _dbService.connect();
      final isHealthy = await _dbService.healthCheck();

      if (isHealthy) {
        setState(() {
          _status =
              kIsWeb
                  ? '✅ Connected to API (Web Mode)'
                  : '✅ Connected to Google Cloud SQL (Direct)';
        });
      } else {
        setState(() {
          _status = '❌ Connection failed';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurants = await _dbService.getRestaurants();
      setState(() {
        _restaurants = restaurants;
        _status = '✅ Fetched ${restaurants.length} restaurants';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error fetching restaurants: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dbService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Cloud SQL Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _testConnection,
                            icon: const Icon(Icons.link),
                            label: const Text('Test Connection'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _fetchRestaurants,
                            icon: const Icon(Icons.restaurant),
                            label: const Text('Fetch Restaurants'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_restaurants.isNotEmpty)
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Restaurants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = _restaurants[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  restaurant['name']?.toString()[0] ?? '?',
                                ),
                              ),
                              title: Text(
                                restaurant['name']?.toString() ?? 'Unknown',
                              ),
                              subtitle: Text(
                                restaurant['address']?.toString() ??
                                    'No address',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Text(
                                    restaurant['rating']?.toString() ?? '0.0',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
