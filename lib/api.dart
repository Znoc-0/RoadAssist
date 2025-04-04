import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl = 'https://parliamentary-catshark-zniker-48328493.koyeb.app';

  Future<http.Response> registerUser({
    required String firstName,
    required String email,
    required String password,
    required String phone,
    required String lastName,
    required int age,
    required String username,
    int balance = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'first_name': firstName,
          'email': email,
          'password': password,
          'phone': phone,
          'last_name': lastName,
          'age': age,
          'username': username,
          'balance': balance,
        }),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to login user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> registerSeller({
    required String pumpName,
    required String Name,
    required String email,
    required String password,
    required String phone,
    // required String lastName,
    required int age,
    required String username,
    required String lat,
    required String long,
    int balance = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'owner_name': Name,
          'email': email,
          'password': password,
          'phone': phone,
          'age': age,
          'username': username,
          'balance': balance,
          'pump_name': pumpName,
          'pump_lat': lat,
          'pump_long': long,

        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to register seller: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> sellerLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to login seller: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> getOrderHistory({
    required String email_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/get_order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to fetch order history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> placeOrder({
    required String email,
    required String fuelType,
    required int amount,
    required String lat,
    required String long,
    required int quantity,
    required String pumpId,
  }) async {
    try {
      print("Placing order with details: $email, $fuelType, $amount, $lat, $long, $quantity, $pumpId");
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/place_order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email': email,

          'fuel_type': fuelType,
          'price': amount,
          'latitude': lat,
          'longitude': long,
          'quantity': quantity,
          'pump_id': pumpId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to place order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> getCurrentUser({
    required String email_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/get_user_info'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to fetch current user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> updateBalance(
      {required double amount, required String email_id}) async {
    try { // Replace with your actual base URL
      final response = await http.post(
        Uri.parse('$baseUrl/user/recharge_balance'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to update balance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error : $e');
    }
  }


  Future<http.Response> getpumpdetails({
    required String email_id,

  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/get_pumps'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to fetch pump details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }



  Future<http.Response> getCurrentSeller ({
    required String email_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/get_seller_info'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to fetch current seller: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> getCurrentStock({
    required String email_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/get_current_stock'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to fetch current stock: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> updateStock({
    required String email_id,
    required String fuel_type,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/update_stock'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
          'fuel_type': fuel_type,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to update stock: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }



  Future<http.Response> getSellerOrders({
    required String email_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/get_all_orders'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Seller orders fetched successfully  ${response.body}");
        return response;
      } else {
        throw Exception('Failed to fetch seller orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> updateOrderStatus({
    required String email_id,
    required String order_id,
    required String status,
    // required String emailId,
    required String deliveryBoy
  }) async {
    try {
      if (deliveryBoy==""){
        deliveryBoy = "null";
      }
      final response = await http.post(
        Uri.parse('$baseUrl/seller/update_order_status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email_id': email_id,
          'order_id': order_id,
          'status': status,
          'deliveryBoy': deliveryBoy,

        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<http.Response> verifyOrderOtp({
    required String email_id,
    required String order_id,
    required String otp,
    required String deliveryBoy,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifyorderotp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email_id': email_id,
        'order_id': order_id,
        'otp': otp,
        'delivery_boy': deliveryBoy,
        'status': 'completed',
      }),
    );
    return response;
  }

}
