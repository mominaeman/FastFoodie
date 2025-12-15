class Customer {
  final int customerId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime? createdAt;
  final bool isAdmin;

  Customer({
    required this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.createdAt,
    this.isAdmin = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Check if user is admin (specific email or from database)
    final email = json['email'] ?? '';
    final isAdmin = email == 'admin@fastfoodie.com' || json['is_admin'] == true;

    return Customer(
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      name: json['name'] ?? '',
      email: email,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      isAdmin: isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'is_admin': isAdmin,
    };
  }

  Customer copyWith({
    int? customerId,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
