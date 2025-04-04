import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadassist/api.dart';
import 'package:roadassist/seller_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellerHomeScreen extends StatefulWidget {
  final String emailId;

  const SellerHomeScreen({Key? key, required this.emailId}) : super(key: key);

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  String? selectedDeliveryBoy;
  final api = Api();
  String emailId = '';
  List<FuelStock> _fuelStocks = [];
  List<Order> _recentOrders = [];
  List<String> _deliveryBoys = [
    'Rahul Sharma',
    'Vikram Singh',
    'Amit Patel',
    'Sanjay Gupta',
  ];

  Timer? _fetchuserinfoTimer;
  Map<String, dynamic>? _sellerInfo;
  bool _isLoading = true;
  bool _showAllOrders = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    emailId = widget.emailId;
    _fetchSellerInfo();

    _fetchuserinfoTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      fetchFuelStocksWithDelay();
      fetchOrdersWithDelay();
    });
  }

  @override
  void dispose() {
    _fetchuserinfoTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSellerInfo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final sellerResponse = await api.getCurrentSeller(email_id: emailId);
      if (sellerResponse.statusCode == 200) {
        final sellerData = json.decode(sellerResponse.body);
        setState(() {
          _sellerInfo = sellerData['seller'];
          _fuelStocks = [
            FuelStock(
              name: 'Petrol',
              price: _sellerInfo?['petrol_price']?.toDouble() ?? 102.50,
              stock: _sellerInfo?['petrol']?.toDouble() ?? 0,
              color: Colors.blue,
            ),
            FuelStock(
              name: 'Diesel',
              price: _sellerInfo?['diesel_price']?.toDouble() ?? 89.75,
              stock: _sellerInfo?['diesel']?.toDouble() ?? 0,
              color: Colors.blue,
            ),
            FuelStock(
              name: 'Premium',
              price: _sellerInfo?['premium_price']?.toDouble() ?? 115.20,
              stock: _sellerInfo?['premium']?.toDouble() ?? 0,
              color: Colors.blue,
            ),
          ];
        });
      }

      final ordersResponse = await api.getSellerOrders(email_id: emailId);
      if (ordersResponse.statusCode == 200) {
        final ordersData = json.decode(ordersResponse.body);
        final List<dynamic> orderList = ordersData['order_data'] ?? [];

        setState(() {
          _recentOrders = orderList.map((order) {
            try {
              final dateParts = (order['order_date'] as String).split('-');
              final timeParts = (order['order_time'] as String).split(':');
              final orderDate = DateTime(
                int.parse(dateParts[2]),
                int.parse(dateParts[1]),
                int.parse(dateParts[0]),
                int.parse(timeParts[0]),
                int.parse(timeParts[1]),
                int.parse(timeParts[2]),
              );

              String status =
                  (order['order_status'] as String?)?.toUpperCase() ?? 'PENDING';
              final localOrder = _recentOrders.firstWhere(
                    (o) => o.id == order['_id'],
                orElse: () => Order(
                  id: order['_id'] ?? 'N/A',
                  fuelType: order['fuel_type'] ?? 'Unknown',
                  quantity: (order['quantity'] as num?)?.toInt() ?? 0,
                  amount: (order['price'] as num?)?.toDouble() ?? 0.0,
                  status: status,
                  date: orderDate,
                  deliveryBoy: order['delivery_boy'],
                  isOtpVerified: order['is_otp_verified'] ?? false,
                ),
              );

              if (order['delivery_boy'] != null && status == 'CONFIRMED') {
                status = 'DELIVERYBOY_ASSIGNED';
              }

              return Order(
                id: order['_id'] ?? 'N/A',
                fuelType: order['fuel_type'] ?? 'Unknown',
                quantity: (order['quantity'] as num?)?.toInt() ?? 0,
                amount: (order['price'] as num?)?.toDouble() ?? 0.0,
                status: localOrder.status == 'DELIVERYBOY_ASSIGNED' ||
                    localOrder.status == 'COMPLETED'
                    ? localOrder.status
                    : status,
                date: orderDate,
                deliveryBoy: localOrder.deliveryBoy ?? order['delivery_boy'],
                isOtpVerified: localOrder.isOtpVerified,
              );
            } catch (e) {
              return Order(
                id: order['_id'] ?? 'N/A',
                fuelType: order['fuel_type'] ?? 'Unknown',
                quantity: (order['quantity'] as num?)?.toInt() ?? 0,
                amount: (order['price'] as num?)?.toDouble() ?? 0.0,
                status: (order['order_status'] as String?)?.toUpperCase() ??
                    'PENDING',
                date: DateTime.now(),
                deliveryBoy: order['delivery_boy'],
                isOtpVerified: order['is_otp_verified'] ?? false,
              );
            }
          }).toList();
          _sortOrders();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<FuelStock>> getFuelStocks(String emailId) async {
    try {
      final response = await api.getCurrentStock(email_id: emailId);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final currentStock = responseData['current_stock'] ?? {};

        return [
          FuelStock(
            name: 'Petrol',
            price: _sellerInfo?['petrol_price']?.toDouble() ?? 102.50,
            stock: (currentStock['petrol'] as num?)?.toDouble() ?? 0,
            color: Colors.blue,
          ),
          FuelStock(
            name: 'Diesel',
            price: _sellerInfo?['diesel_price']?.toDouble() ?? 89.75,
            stock: (currentStock['diesel'] as num?)?.toDouble() ?? 0,
            color: Colors.blue,
          ),
          FuelStock(
            name: 'Premium',
            price: _sellerInfo?['premium_price']?.toDouble() ?? 115.20,
            stock: (currentStock['premium'] as num?)?.toDouble() ?? 0,
            color: Colors.blue,
          ),
        ];
      } else {
        throw Exception('Failed to load fuel stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fuel stocks: ${e.toString()}');
    }
  }

  Future<void> fetchFuelStocksWithDelay() async {
    await Future.delayed(const Duration(seconds: 5));

    try {
      final stocks = await getFuelStocks(emailId);
      setState(() {
        _fuelStocks = stocks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating fuel stocks: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Order>> getOrders(String emailId) async {
    try {
      final ordersResponse = await api.getSellerOrders(email_id: emailId);

      if (ordersResponse.statusCode == 200) {
        final ordersData = json.decode(ordersResponse.body);
        final List<dynamic> orderList = ordersData['order_data'] ?? [];

        return orderList.map((order) {
          try {
            final dateParts = (order['order_date'] as String).split('-');
            final timeParts = (order['order_time'] as String).split(':');
            final orderDate = DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              int.parse(timeParts[2]),
            );

            String status =
                (order['order_status'] as String?)?.toUpperCase() ?? 'PENDING';
            if (order['delivery_boy'] != null && status == 'CONFIRMED') {
              status = 'DELIVERYBOY_ASSIGNED';
            }

            return Order(
              id: order['_id'] ?? 'N/A',
              fuelType: order['fuel_type'] ?? 'Unknown',
              quantity: (order['quantity'] as num?)?.toInt() ?? 0,
              amount: (order['price'] as num?)?.toDouble() ?? 0.0,
              status: status,
              date: orderDate,
              deliveryBoy: order['delivery_boy'],
              isOtpVerified: order['is_otp_verified'] ?? false,
            );
          } catch (e) {
            return Order(
              id: order['_id'] ?? 'N/A',
              fuelType: order['fuel_type'] ?? 'Unknown',
              quantity: (order['quantity'] as num?)?.toInt() ?? 0,
              amount: (order['price'] as num?)?.toDouble() ?? 0.0,
              status: (order['order_status'] as String?)?.toUpperCase() ??
                  'PENDING',
              date: DateTime.now(),
              deliveryBoy: order['delivery_boy'],
              isOtpVerified: order['is_otp_verified'] ?? false,
            );
          }
        }).toList();
      } else {
        throw Exception('Failed to load orders: ${ordersResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: ${e.toString()}');
    }
  }

  Future<void> fetchOrdersWithDelay() async {
    await Future.delayed(const Duration(seconds: 5));

    try {
      final orders = await getOrders(emailId);
      setState(() {
        _recentOrders = orders.map((serverOrder) {
          final localOrder = _recentOrders.firstWhere(
                (o) => o.id == serverOrder.id,
            orElse: () => serverOrder,
          );
          return serverOrder.copyWith(
            deliveryBoy: localOrder.deliveryBoy ?? serverOrder.deliveryBoy,
            status: localOrder.status == 'DELIVERYBOY_ASSIGNED' ||
                localOrder.status == 'COMPLETED'
                ? localOrder.status
                : serverOrder.status,
            isOtpVerified: localOrder.isOtpVerified,
          );
        }).toList();
        _sortOrders();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching orders: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sortOrders() {
    setState(() {
      _recentOrders.sort((a, b) {
        if (a.status == 'PENDING' && b.status != 'PENDING') return -1;
        if (a.status != 'PENDING' && b.status == 'PENDING') return 1;
        if (a.status == 'CONFIRMED' && b.status == 'COMPLETED') return -1;
        if (a.status == 'COMPLETED' && b.status == 'CONFIRMED') return 1;
        return b.date.compareTo(a.date);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _fetchSellerInfo,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _sellerInfo?['pump_name'] ?? 'Road Assist',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SellerAccountScreen(
                                          emailId: emailId,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome back, ${_sellerInfo?['owner_name'] ?? emailId}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pump Location',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat: ${_sellerInfo?['pump_lat'] ?? 'N/A'}, Long: ${_sellerInfo?['pump_long'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fuel Stock',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _fuelStocks.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final fuel = _fuelStocks[index];
                              return _buildFuelStockCard(fuel, index);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Orders',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllOrders = !_showAllOrders;
                                });
                              },
                              child: Text(
                                _showAllOrders ? 'Show Less' : 'View All',
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final order = _recentOrders[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 12,
                    ),
                    child: _buildOrderCard(order),
                  );
                },
                childCount: _showAllOrders
                    ? _recentOrders.length
                    : (_recentOrders.length > 3
                    ? 3
                    : _recentOrders.length),
              ),
            ),
            if (!_showAllOrders && _recentOrders.length > 3)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '+ ${_recentOrders.length - 3} more orders',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelStockCard(FuelStock fuel, int index) {
    return GestureDetector(
      onTap: () => _showFuelEditDialog(index),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getFuelIcon(fuel.name),
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fuel.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${fuel.price.toStringAsFixed(2)}/L',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${fuel.stock}L',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    bool isAssigning = false;

    debugPrint(
      'Order Status: ${order.status}, Delivery Boy: ${order.deliveryBoy}, OTP Verified: ${order.isOtpVerified}',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getFuelIcon(order.fuelType),
                    color: Colors.blue[700],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  order.fuelType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.status == 'COMPLETED'
                        ? Colors.green.withOpacity(0.1)
                        : order.status == 'CONFIRMED' ||
                        order.status == 'DELIVERYBOY_ASSIGNED'
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: order.status == 'COMPLETED'
                          ? Colors.green
                          : order.status == 'CONFIRMED' ||
                          order.status == 'DELIVERYBOY_ASSIGNED'
                          ? Colors.blue
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(order.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${order.quantity}L',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            if (order.status == 'PENDING') ...[
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _confirmOrder(order);
                },
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            if (order.status == 'CONFIRMED' && order.deliveryBoy == null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedDeliveryBoy,
                decoration: const InputDecoration(
                  labelText: 'Select Delivery Partner',
                  border: OutlineInputBorder(),
                ),
                items: _deliveryBoys.map((boy) {
                  return DropdownMenuItem<String>(
                    value: boy,
                    child: Text(boy),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryBoy = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (selectedDeliveryBoy != null)
                ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () async {
                    setState(() => isAssigning = true);
                    await _assignDeliveryBoy(order, selectedDeliveryBoy!);
                    setState(() => isAssigning = false);
                  },
                  child: isAssigning
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Assign Delivery Partner'),
                ),
            ],
            if (order.status == 'DELIVERYBOY_ASSIGNED' && !order.isOtpVerified) ...[
              const SizedBox(height: 12),
              Text(
                'Assigned to: ${order.deliveryBoy ?? 'Not assigned'}',
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isVerifying
                    ? null
                    : () async {
                  if (otpController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter OTP'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (order.deliveryBoy == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No delivery boy assigned'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() => isVerifying = true);
                  await _verifyOrderOtp(order, otpController.text);
                  setState(() => isVerifying = false);
                },
                child: isVerifying
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify OTP'),
              ),
            ],
            if (order.isOtpVerified) ...[
              const SizedBox(height: 12),
              Text(
                'Verified by: ${order.deliveryBoy}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _assignDeliveryBoy(Order order, String deliveryBoy) async {
    try {
      final response = await api.updateOrderStatus(
        email_id: emailId,
        order_id: order.id,
        status: 'DELIVERYBOY_ASSIGNED',
        deliveryBoy: deliveryBoy,
      );

      if (response.statusCode == 200) {
        setState(() {
          _recentOrders = _recentOrders.map((o) {
            if (o.id == order.id) {
              return o.copyWith(
                status: 'DELIVERYBOY_ASSIGNED',
                deliveryBoy: deliveryBoy,
              );
            }
            return o;
          }).toList();
          _sortOrders();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery partner assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign delivery partner: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOrderOtp(Order order, String otp) async {
    try {
      final response = await api.verifyOrderOtp(
        email_id: emailId,
        order_id: order.id,
        otp: otp,
        deliveryBoy: order.deliveryBoy!,
      );

      if (response.statusCode == 200) {
        setState(() {
          _recentOrders = _recentOrders.map((o) {
            if (o.id == order.id) {
              return o.copyWith(status: 'COMPLETED', isOtpVerified: true);
            }
            return o;
          }).toList();
          _sortOrders();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmOrder(Order order) async {
    try {
      final response = await api.updateOrderStatus(
        email_id: emailId,
        order_id: order.id,
        status: 'CONFIRMED',
        deliveryBoy: "",
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _recentOrders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            _recentOrders[index] = order.copyWith(
              status: 'CONFIRMED',
              deliveryBoy: null,
            );
            _sortOrders();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id.substring(0, 8)} confirmed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFuelEditDialog(int index) {
    final fuel = _fuelStocks[index];
    final priceController = TextEditingController(text: fuel.price.toString());
    final stockController = TextEditingController(text: fuel.stock.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update ${fuel.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: 'Stock (Liters)',
                  suffixText: 'L',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      final newPrice =
                          double.tryParse(priceController.text) ?? fuel.price;
                      final newStock =
                          double.tryParse(stockController.text) ?? fuel.stock;

                      try {
                        final response = await api.updateStock(
                          email_id: emailId,
                          fuel_type: fuel.name.toLowerCase(),
                          quantity: newStock.toInt(),
                        );

                        if (response.statusCode == 200) {
                          setState(() {
                            _fuelStocks[index] = fuel.copyWith(
                              price: newPrice,
                              stock: newStock,
                            );
                            if (_sellerInfo != null) {
                              _sellerInfo!['${fuel.name.toLowerCase()}_price'] =
                                  newPrice;
                              _sellerInfo![fuel.name.toLowerCase()] = newStock;
                            }
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text('${fuel.name} updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          throw Exception('Failed to update stock');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFuelIcon(String fuelType) {
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
}

class FuelStock {
  final String name;
  final double price;
  final double stock;
  final Color color;

  FuelStock({
    required this.name,
    required this.price,
    required this.stock,
    required this.color,
  });

  FuelStock copyWith({
    String? name,
    double? price,
    double? stock,
    Color? color,
  }) {
    return FuelStock(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      color: color ?? this.color,
    );
  }
}

class Order {
  final String id;
  final String fuelType;
  final int quantity;
  final double amount;
  final String status;
  final DateTime date;
  final bool isOtpVerified;
  String? deliveryBoy;

  Order({
    required this.id,
    required this.fuelType,
    required this.quantity,
    required this.amount,
    required this.status,
    required this.date,
    this.isOtpVerified = false,
    this.deliveryBoy,
  });

  Order copyWith({
    String? id,
    String? fuelType,
    int? quantity,
    double? amount,
    String? status,
    DateTime? date,
    bool? isOtpVerified,
    String? deliveryBoy,
  }) {
    return Order(
      id: id ?? this.id,
      fuelType: fuelType ?? this.fuelType,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      deliveryBoy: deliveryBoy ?? this.deliveryBoy,
    );
  }
}