import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roadassist/Account.dart';
import 'package:roadassist/api.dart';
import 'package:roadassist/ev.dart';
import 'package:roadassist/evcharge.dart';
import 'package:roadassist/workshop.dart';

class UserHomeScreen extends StatefulWidget {
  final String email_id;

  const UserHomeScreen({Key? key, required this.email_id}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String first_name = '';
  String last_name = '';
  String phone = '';
  Pump? _selectedPump;
  String username = '';
  String age = '';
  String balance = '';

  late String email_id;
  final api = Api();
  late Location _location;
  LatLng? _currentLocation;
  bool _isLoading = false;
  bool _isLoadingButton = false;
  int _selectedFuelIndex = -1;
  int _selectedQuantity = 1;
  bool _showQuantitySelector = false;
  List<Order> _orderHistory = [];
  Timer? _orderHistoryTimer;
  Timer? _locationTimer;
  // Fuel types
  final List<FuelType> _fuelTypes = [
    FuelType(
      name: 'Petrol',
      price: 102.50,
      icon: Icons.local_gas_station,
      color: Colors.green,
    ),
    FuelType(
      name: 'Diesel',
      price: 89.75,
      icon: Icons.local_shipping,
      color: Colors.blue,
    ),
    FuelType(
      name: 'Premium',
      price: 115.20,
      icon: Icons.star,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    email_id = widget.email_id;
    _location = Location();
    _fetchLocation();
    _fetchOrderHistory();
    getcurrentUser();

    _orderHistoryTimer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer t) => _fetchOrderHistory(),
    );
    _locationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer t) => _fetchLocation(),
    );
  }

  @override
  void dispose() {
    _orderHistoryTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> getcurrentUser() async {
    try {
      final response = await api.getCurrentUser(email_id: email_id);
      final responseData = json.decode(response.body);
      if (responseData['user_data'] != null) {
        final userData = responseData['user_data'];

        setState(() {
          first_name = userData['first_name'] ?? '';
          last_name = userData['last_name'] ?? '';
          phone = userData['phone'] ?? '';
          username = userData['username'] ?? '';
          age = userData['age']?.toString() ?? '';
          balance = userData['balance']?.toString() ?? '0';
        });

        // Handle user data
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(locData.latitude!, locData.longitude!);
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchOrderHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    setState(() {
      _isLoadingButton = false;
    });

    try {
      final response = await api.getOrderHistory(email_id: email_id);
      final responseData = json.decode(response.body);

      if (responseData['order_data'] != null) {
        final List<Order> newOrders =
            (responseData['order_data'] as List)
                .map((orderJson) => Order.fromJson(orderJson))
                .toList();

        newOrders.sort((a, b) => b.date.compareTo(a.date));

        // Check for newly approved orders
        if (_orderHistory.isNotEmpty && newOrders.isNotEmpty) {
          for (final newOrder in newOrders) {
            try {
              final oldOrder = _orderHistory.firstWhere(
                (order) => order.id == newOrder.id,
                orElse:
                    () => Order(
                      id: '',
                      email: '',
                      status: '',
                      date: DateTime.now(),
                      price: 0,
                      fuelType: '',
                      quantity: 0,
                      latitude: '',
                      longitude: '',
                    ),
              );

              if (oldOrder.id.isNotEmpty &&
                  oldOrder.status != 'in progress' &&
                  newOrder.status == 'in progress') {
                _showApprovalNotification(newOrder);
              }
            } catch (e) {
              print("Error comparing order ${newOrder.id}: $e");
            }
          }
        }

        if (mounted) {
          setState(() => _orderHistory = newOrders);
        }
      }
    } catch (e) {
      print("Error fetching orders: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to load orders")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        setState(() {
          _isLoadingButton = false;
        });
      }
    }
  }

  void _showApprovalNotification(Order approvedOrder) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${approvedOrder.id} has been approved!'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to order details if needed
            // Navigator.push(...);
          },
        ),
      ),
    );

    // You can also trigger other notifications like:
    // - System notifications (using flutter_local_notifications)
    // - Haptic feedback
    // - Sound alerts
  }

  Future<void> _placeOrder() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not available!")));
      return;
    }
    if (_selectedPump == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a fuel station first")),
      );
      return;
    }

    setState(() => _isLoadingButton = true);

    try {
      await api.placeOrder(
        email: email_id,
        fuelType: _fuelTypes[_selectedFuelIndex].name,
        amount:
            (_fuelTypes[_selectedFuelIndex].price * _selectedQuantity).toInt(),
        lat: _currentLocation!.latitude.toString(),
        long: _currentLocation!.longitude.toString(),
        quantity: _selectedQuantity,
        pumpId: _selectedPump!.id,
      );

      await _fetchOrderHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order placed successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedFuelIndex = -1;
        _selectedQuantity = 1;
        _showQuantitySelector = false;
      });
    } catch (e) {
      print("Error placing order: $e");
      String errorMessage = "Failed to place order";

      try {
        final errorString = e.toString();
        final jsonStart = errorString.indexOf('{');
        if (jsonStart != -1) {
          final jsonPart = errorString.substring(jsonStart);
          final errorData = jsonDecode(jsonPart);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey("message")) {
            errorMessage = errorData["message"];
          }
        }
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
    // setState(() => _isLoading = false);
    setState(() {
      _isLoadingButton = false;
    });
  }

  void _viewOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(orderHistory: _orderHistory),
      ),
    );
  }

  Future<void> _viewMap() async {
    _selectedPump = null;
    if (_currentLocation != null) {
      final selectedPump = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MapScreen(
                email_id: email_id,
                onPumpSelected: (pump) {
                  // Optional: Immediate callback when marker is tapped
                  print('Pump selected: ${pump.name}, ${pump.id}');
                },
              ),
        ),
      );
      if (selectedPump != null) {
        setState(() {
          _selectedPump = selectedPump;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${selectedPump.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectFuelType(int index) {
    setState(() {
      _selectedFuelIndex = index;
      _showQuantitySelector = true;
      _selectedQuantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.blue[700],
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                "OTHERS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text("EV Charging"),
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EVStationsPage(emailId: email_id),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Workshop Services"),
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  WorkshopPage(emailId: email_id,),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Road Assist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(email_id: email_id),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back,",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${first_name.isNotEmpty ? '$first_name ' : ''}${last_name.isNotEmpty ? last_name : 'User'}",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            _currentLocation != null
                                ? const Text(
                                  "Your location has been detected",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                )
                                : const Text(
                                  "Detecting your location...",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                      TextButton(
                        onPressed: _viewMap,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "View Map",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _selectedPump != null
                        ? "Selected: ${_selectedPump!.name}"
                        : "No station selected",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Main content
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Select Fuel Type",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Fuel type buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFuelTypeButton(0),
                  const SizedBox(width: 12),
                  _buildFuelTypeButton(1),
                  const SizedBox(width: 12),
                  _buildFuelTypeButton(2),
                ],
              ),
            ),

            // Quantity selector
            if (_showQuantitySelector)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Quantity (Liters)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final quantity = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuantity = quantity;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  _selectedQuantity == quantity
                                      ? _fuelTypes[_selectedFuelIndex].color
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    _selectedQuantity == quantity
                                        ? _fuelTypes[_selectedFuelIndex].color
                                        : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "$quantity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedQuantity == quantity
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total: ₹${(_fuelTypes[_selectedFuelIndex].price * _selectedQuantity).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Order button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed:
                    _selectedFuelIndex >= 0 && !_isLoadingButton
                        ? _placeOrder
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoadingButton
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Place Fuel Order",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent orders section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Recent Orders",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_orderHistory.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${_orderHistory.length}",
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _viewOrderHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Order history list
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _orderHistory.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "No orders yet",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: min(_orderHistory.length, 5),
                        itemBuilder: (context, index) {
                          final order = _orderHistory[index];
                          final fuelColor =
                              _fuelTypes
                                  .firstWhere(
                                    (type) => type.name == order.fuelType,
                                    orElse: () => _fuelTypes[0],
                                  )
                                  .color;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: fuelColor.withOpacity(0.2),
                                child: Icon(
                                  _getFuelTypeIcon(order.fuelType),
                                  color: fuelColor,
                                ),
                              ),
                              title: Text(
                                "${order.fuelType} (${order.quantity}L)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(order.date)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${order.price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (order.status =='DELIVERYBOY_ASSIGNED') ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 500,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (order.deliveryPerson != null)
                                            Text(
                                              "Delivery Person: ${order.deliveryPerson!}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          if (order.otp != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Text(
                                                  "OTP: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  order.otp!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeButton(int index) {
    final fuelType = _fuelTypes[index];
    bool isSelected = _selectedFuelIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectFuelType(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120,
          decoration: BoxDecoration(
            color: isSelected ? fuelType.color[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? fuelType.color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: fuelType.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(fuelType.icon, size: 32, color: fuelType.color),
              const SizedBox(height: 8),
              Text(
                fuelType.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${fuelType.price}/L",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'delivery assigned ':
        return Colors.yellow;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getFuelTypeIcon(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
        return Icons.local_gas_station;
      case 'diesel':
        return Icons.local_shipping;
      case 'premium':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class OrderHistoryScreen extends StatelessWidget {
  final List<Order> orderHistory;

  const OrderHistoryScreen({super.key, required this.orderHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
      ),
      body:
          orderHistory.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No order history found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  final order = orderHistory[index];
                  final fuelColor = _getFuelColor(order.fuelType);

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order #${order.id.substring(0, 8)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(
                                _getFuelTypeIcon(order.fuelType),
                                color: fuelColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${order.fuelType} (${order.quantity}L)",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Text(
                                "₹${order.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(order.date),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Lat: ${order.latitude}, Lng: ${order.longitude}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Color _getFuelColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
        return Colors.green;
      case 'diesel':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getFuelTypeIcon(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
        return Icons.local_gas_station;
      case 'diesel':
        return Icons.local_shipping;
      case 'premium':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class Pump {
  final String id;
  final String name;
  final double lat;
  final double long;
  final String phone;

  Pump({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.phone,
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      id: json['_id'],
      name: json['pump_name'],
      lat: double.parse(json['pump_lat']),
      long: double.parse(json['pump_long']),
      phone: json['phone'],
    );
  }
}

class MapScreen extends StatefulWidget {
  final String email_id;
  final LatLng? currentLocation;
  final Function(Pump)? onPumpSelected;

  const MapScreen({
    Key? key,
    this.currentLocation,
    required this.email_id,
    this.onPumpSelected,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Pump? _selectedPump;
  final api = Api();
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  final Location _location = Location();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _apiError = false;

  @override
  void initState() {
    super.initState();

    // if (_currentLocation == null) {
    //   _getCurrentLocation();
    // } else {
    //   _loadNearbyStations();
    //   _isLoading = false;
    // }
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    try {
      // Set initial location from widget or get current location
      _currentLocation = widget.currentLocation;

      if (_currentLocation == null) {
        await _getCurrentLocation();
      } else {
        await _loadNearbyStations();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error initializing map: $e");
      setState(() {
        _isLoading = false;
        _apiError = true;
      });
    }
  }

  void _handlePumpSelection(Pump pump) {
    setState(() {
      _selectedPump = pump;
    });

    // Show info window programmatically
    _mapController.showMarkerInfoWindow(MarkerId(pump.id));

    // Zoom to selected pump
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pump.lat, pump.long), 16),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      var locData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(locData.latitude!, locData.longitude!);
        _isLoading = false;
      });

      _loadNearbyStations();

      if (_currentLocation != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 15),
        );
      }
    } catch (e) {

      print("Error getting location: $e");

      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyStations() async {
    if (_currentLocation == null) return;

    try {
      setState(() {
        _isLoading = true;
        _apiError = false;
        _selectedPump = null;
      });

      // First, create a marker for current location
      final markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };

      // Make actual API call
      final response = await api.getpumpdetails(email_id: widget.email_id);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['message'] == "Pumps fetched successfully") {
          final pumps =
              (responseData['pumps_data'] as List)
                  .map((json) => Pump.fromJson(json))
                  .toList();

          for (var pump in pumps) {
            markers.add(
              Marker(
                markerId: MarkerId(pump.id),
                position: LatLng(pump.lat, pump.long),
                infoWindow: InfoWindow(
                  title: pump.name,
                  snippet: "${pump.lat}, ${pump.long}",
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                onTap: () => _handlePumpSelection(pump),
              ),
            );
          }
        } else {
          // Handle API message error
          print('API error: ${responseData['message']}');
          throw Exception('Failed to fetch pumps: ${responseData['message']}');
        }
      } else {
        // Handle HTTP error
        print('HTTP error: ${response.statusCode}');
        throw Exception('Failed to load pumps: ${response.statusCode}');
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading nearby stations: $e');
      setState(() {
        _isLoading = false;
        _apiError = true;
        // Fallback to dummy data
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
          Marker(
            markerId: const MarkerId('station_1'),
            position: LatLng(
              _currentLocation!.latitude + 0.005,
              _currentLocation!.longitude - 0.003,
            ),
            infoWindow: const InfoWindow(
              title: 'City Fuel Station',
              snippet: '4.5 ★',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
          Marker(
            markerId: const MarkerId('station_2'),
            position: LatLng(
              _currentLocation!.latitude - 0.004,
              _currentLocation!.longitude + 0.006,
            ),
            infoWindow: const InfoWindow(
              title: 'Highway Petrol Pump',
              snippet: '4.2 ★',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuel Stations Nearby"),
        backgroundColor: Colors.blue[700],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Location not available",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  if (_apiError)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Could not load stations. Showing sample data.',
                                  style: TextStyle(color: Colors.orange[800]),
                                ),
                              ),
                              TextButton(
                                onPressed: _loadNearbyStations,
                                child: Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.orange[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: "zoom_in",
                          mini: true,
                          onPressed: () {
                            _mapController.animateCamera(CameraUpdate.zoomIn());
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: "zoom_out",
                          mini: true,
                          onPressed: () {
                            _mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (_currentLocation != null) {
                          _mapController.animateCamera(
                            CameraUpdate.newLatLngZoom(_currentLocation!, 15),
                          );
                        }
                      },
                      backgroundColor: Colors.blue[700],
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Your Location",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_selectedPump != null) {
                                  // Return the selected pump both through callback and Navigator
                                  widget.onPumpSelected?.call(_selectedPump!);
                                  Navigator.pop(context, _selectedPump);
                                } else {
                                  // Show error if no pump selected
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a fuel station first',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _selectedPump != null
                                    ? "Order from ${_selectedPump!.name}"
                                    : "Select Station & Order",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class FuelType {
  final String name;
  final double price;
  final IconData icon;
  final MaterialColor color;

  const FuelType({
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
  });
}

class Order {
  final String id;
  final String email;
  final String status;
  final DateTime date;
  final double price;
  final String fuelType;
  final int quantity;
  final String latitude;
  final String longitude;
  final String? otp;
  final String? deliveryPerson;

  Order({
    required this.id,
    required this.email,
    required this.status,
    required this.date,
    required this.price,
    required this.fuelType,
    required this.quantity,
    required this.latitude,
    required this.longitude,
    this.otp,
    this.deliveryPerson,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      final dateParts = (json['order_date'] as String).split('-');
      final timeParts = (json['order_time'] as String).split(':');

      final date = DateTime(
        2000 + int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      return Order(
        id: json['_id'] ?? '',
        email: json['email_id'] ?? '',
        status: json['order_status'] ?? 'pending',
        date: date,
        price: (json['price'] as num).toDouble(),
        fuelType: json['fuel_type'] ?? '',
        quantity: json['quantity'] ?? 0,
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        otp: json['otp']?.toString(), // Add this
        deliveryPerson: json['delivery_person']?.toString(),
      );
    } catch (e) {
      print('Error parsing order date: $e');
      return Order(
        id: json['_id'] ?? '',
        email: json['email_id'] ?? '',
        status: json['order_status'] ?? 'pending',
        date: DateTime.now(),
        price: (json['price'] as num).toDouble(),
        fuelType: json['fuel_type'] ?? '',
        quantity: json['quantity'] ?? 0,
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        otp: json['otp']?.toString(), // Add this
        deliveryPerson: json['delivery_person']?.toString(),
      );
    }
  }
}
