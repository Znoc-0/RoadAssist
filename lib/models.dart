// models.dart
class PumpDetails {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;

  PumpDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
  });
}

class Order {
  final String id;
  final String customerName;
  final String fuelType;
  final int quantity;
  final double amount;
  final String status;
  final DateTime date;
  final String? deliveryPartner;

  Order({
    required this.id,
    required this.customerName,
    required this.fuelType,
    required this.quantity,
    required this.amount,
    required this.status,
    required this.date,
    this.deliveryPartner,
  });

  Order copyWith({
    String? id,
    String? customerName,
    String? fuelType,
    int? quantity,
    double? amount,
    String? status,
    DateTime? date,
    String? deliveryPartner,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      fuelType: fuelType ?? this.fuelType,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
    );
  }
}

class DeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final String status;
  final double rating;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.rating,
  });

  DeliveryPartner copyWith({
    String? id,
    String? name,
    String? phone,
    String? status,
    double? rating,
  }) {
    return DeliveryPartner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }
}

class FuelPrices {
  final double petrol;
  final double diesel;
  final double premium;

  FuelPrices({
    required this.petrol,
    required this.diesel,
    required this.premium,
  });
}