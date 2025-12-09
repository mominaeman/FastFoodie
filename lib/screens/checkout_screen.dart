import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Customer customer;

  const CheckoutScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedAddress = '';
  String selectedPaymentMethod = 'COD';
  final TextEditingController _deliveryInstructionsController =
      TextEditingController();

  final List<Map<String, String>> savedAddresses = [
    {'label': 'Home', 'address': 'House 123, Street 4, Karachi'},
    {'label': 'Work', 'address': 'Office 5, Floor 2, IT Tower, Lahore'},
    {'label': 'Other', 'address': 'Apartment 7B, Building 3, Islamabad'},
  ];

  @override
  void initState() {
    super.initState();
    // Set default address from customer profile
    selectedAddress =
        widget.customer.address.isNotEmpty
            ? widget.customer.address
            : savedAddresses.first['address']!;
  }

  @override
  void dispose() {
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  void _proceedToConfirmation() {
    if (selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationScreen(
              customer: widget.customer,
              deliveryAddress: selectedAddress,
              paymentMethod: selectedPaymentMethod,
              deliveryInstructions: _deliveryInstructionsController.text,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    const deliveryFee = 50.0;
    final subtotal = cartProvider.totalAmount;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deliver To Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      const Text(
                        'Deliver To',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address Selection
                  ...savedAddresses.map(
                    (addr) => RadioListTile<String>(
                      value: addr['address']!,
                      groupValue: selectedAddress,
                      onChanged: (value) {
                        setState(() {
                          selectedAddress = value!;
                        });
                      },
                      title: Text(
                        addr['label']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(addr['address']!),
                      activeColor: Colors.deepOrange,
                    ),
                  ),

                  // Add New Address Button
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add address screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Add address functionality coming soon!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Payment Method Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  RadioListTile<String>(
                    value: 'COD',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                    title: const Text('Cash on Delivery (COD)'),
                    subtitle: const Text('Pay when you receive your order'),
                    activeColor: Colors.deepOrange,
                  ),

                  RadioListTile<String>(
                    value: 'Card',
                    groupValue: selectedPaymentMethod,
                    onChanged: null,
                    title: const Text('Credit/Debit Card'),
                    subtitle: const Text('Coming soon'),
                    activeColor: Colors.deepOrange,
                  ),

                  RadioListTile<String>(
                    value: 'Online',
                    groupValue: selectedPaymentMethod,
                    onChanged: null,
                    title: const Text('Online Payment'),
                    subtitle: const Text('JazzCash, EasyPaisa - Coming soon'),
                    activeColor: Colors.deepOrange,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Bill Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal (${cartProvider.itemCount} items)',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rs. ${subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Fee', style: TextStyle(fontSize: 16)),
                      Text('Rs. 50', style: TextStyle(fontSize: 16)),
                    ],
                  ),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Delivery Instructions Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Delivery Instructions (Optional)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _deliveryInstructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'E.g., Ring the doorbell, Leave at the gate, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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

            const SizedBox(height: 80),
          ],
        ),
      ),

      // Place Order Button
      bottomNavigationBar: Container(
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
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Proceed • Rs. ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
