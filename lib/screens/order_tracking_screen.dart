import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String restaurantName;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  int currentStep = 0;
  Timer? _timer;
  late AnimationController _animationController;
  String orderStatus = 'pending';

  final Map<String, int> statusToStep = {
    'pending': 0,
    'confirmed': 0,
    'preparing': 1,
    'ready': 2,
    'out_for_delivery': 2,
    'delivered': 3,
  };

  final List<Map<String, dynamic>> orderSteps = [
    {
      'title': 'Order Placed',
      'subtitle': 'We have received your order',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'title': 'In the kitchen',
      'subtitle': 'Your order is being prepared',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'title': 'On the way',
      'subtitle': 'Rider is on the way to deliver',
      'icon': Icons.delivery_dining,
      'color': Colors.blue,
    },
    {
      'title': 'Delivered',
      'subtitle': 'Order delivered successfully',
      'icon': Icons.done_all,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    // Fetch initial order status
    _fetchOrderStatus();

    // Simulate order progress (in real app, fetch from API periodically)
    _startOrderSimulation();
  }

  Future<void> _fetchOrderStatus() async {
    try {
      final orderData = await ApiService.getOrderDetails(widget.orderId);
      if (mounted) {
        setState(() {
          orderStatus = orderData['status'] ?? 'pending';
          currentStep = statusToStep[orderStatus] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }

  void _startOrderSimulation() {
    // Check order status every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _fetchOrderStatus();

      // Auto-progress for demo (remove in production)
      if (currentStep < orderSteps.length - 1) {
        // Simulate status updates
        final statuses = [
          'pending',
          'preparing',
          'out_for_delivery',
          'delivered',
        ];
        if (currentStep < statuses.length - 1) {
          try {
            await ApiService.updateOrderStatus(
              widget.orderId,
              statuses[currentStep + 1],
            );
            await _fetchOrderStatus();
          } catch (e) {
            print('Error updating status: $e');
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.fastfood, size: 60, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'Order #${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.restaurantName,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentStep == orderSteps.length - 1
                        ? 'Order Delivered!'
                        : 'Estimated time: ${(orderSteps.length - currentStep - 1) * 15} mins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Status Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: orderSteps.length,
              itemBuilder: (context, index) {
                final step = orderSteps[index];
                final isCompleted = index <= currentStep;
                final isActive = index == currentStep;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        // Circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isCompleted
                                    ? step['color']
                                    : Colors.grey.shade300,
                            border: Border.all(
                              color:
                                  isCompleted
                                      ? step['color']
                                      : Colors.grey.shade400,
                              width: 3,
                            ),
                          ),
                          child:
                              isActive
                                  ? AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale:
                                            1.0 +
                                            (_animationController.value * 0.1),
                                        child: Icon(
                                          step['icon'],
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                  : Icon(
                                    isCompleted ? Icons.check : step['icon'],
                                    color:
                                        isCompleted
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                    size: 24,
                                  ),
                        ),
                        // Line
                        if (index < orderSteps.length - 1)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 3,
                            height: 80,
                            color:
                                isCompleted
                                    ? step['color']
                                    : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Step content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isCompleted
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['subtitle'],
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isCompleted
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade500,
                              ),
                            ),
                            if (isActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              step['color'],
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'In Progress...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: step['color'],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isCompleted && !isActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateTime.now()
                                      .subtract(
                                        Duration(
                                          minutes: (currentStep - index) * 5,
                                        ),
                                      )
                                      .toString()
                                      .substring(11, 16),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Action Buttons
          if (currentStep == orderSteps.length - 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implement rate order
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rating feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Rate Order'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
