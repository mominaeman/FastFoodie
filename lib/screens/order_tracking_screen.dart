import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../models/customer.dart';
import 'home_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String restaurantName;
  final Customer customer;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.restaurantName,
    required this.customer,
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

  // Rider info
  String? riderName;
  String? riderPhone;
  String? vehicleType;
  bool hasDeliveryInfo = false;

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
        final newStatus = orderData['status'] ?? 'pending';
        print('🔍 Order ${widget.orderId} status: $newStatus');

        setState(() {
          orderStatus = newStatus;
          currentStep = statusToStep[orderStatus] ?? 0;
        });

        // Fetch delivery info if order is out for delivery or delivered
        if (orderStatus == 'out_for_delivery' || orderStatus == 'delivered') {
          print('🚚 Fetching delivery info for order ${widget.orderId}...');
          await _fetchDeliveryInfo();
        }
      }
    } catch (e) {
      print('❌ Error fetching order status: $e');
    }
  }

  Future<void> _fetchDeliveryInfo() async {
    try {
      print('📡 Calling getDeliveryForOrder(${widget.orderId})...');
      final deliveryData = await ApiService.getDeliveryForOrder(widget.orderId);

      if (deliveryData != null) {
        print('✅ Delivery data received: $deliveryData');
        if (mounted) {
          setState(() {
            riderName = deliveryData['rider_name'];
            riderPhone = deliveryData['rider_phone'];
            vehicleType = deliveryData['vehicle_type'];
            hasDeliveryInfo = true;
          });
          print(
            '✅ Rider info updated: $riderName ($vehicleType) - $riderPhone',
          );
        }
      } else {
        print('⚠️ No delivery data found for order ${widget.orderId}');
      }
    } catch (e) {
      print('❌ Error fetching delivery info: $e');
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

  void _showRatingDialog() {
    int selectedRating = 5;
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Column(
                    children: [
                      Icon(Icons.star, size: 40, color: Colors.amber),
                      SizedBox(height: 8),
                      Text(
                        'Rate Your Order',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'How was your experience?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        // Star Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 40,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedRating == 5
                              ? 'Excellent!'
                              : selectedRating == 4
                              ? 'Good'
                              : selectedRating == 3
                              ? 'Average'
                              : selectedRating == 2
                              ? 'Below Average'
                              : 'Poor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                selectedRating >= 4
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Feedback TextField
                        TextField(
                          controller: feedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Share your feedback (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.deepOrange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Show thank you message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Thank you for your $selectedRating-star rating!',
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        // TODO: Send rating to backend
                        // ApiService.rateOrder(widget.orderId, selectedRating, feedbackController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
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

          // Rider Info Card (show when delivery is assigned)
          if (hasDeliveryInfo && riderName != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining,
                        size: 32,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Delivery Rider',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            riderName!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.two_wheeler,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehicleType ?? 'bike',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (riderPhone != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            // In real app, use url_launcher to call
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Call rider: $riderPhone'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate back to home screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  HomeScreen(customer: widget.customer),
                        ),
                        (route) => false,
                      );
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
                if (currentStep == orderSteps.length - 1)
                  const SizedBox(height: 8),
                if (currentStep == orderSteps.length - 1)
                  OutlinedButton.icon(
                    onPressed: () => _showRatingDialog(),
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Rate Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      side: const BorderSide(color: Colors.deepOrange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
