import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadassist/api.dart';
import 'package:roadassist/homeUser.dart';
// import 'package:roadassist/models.dart';

class UserHomeContent extends StatefulWidget {
  final String email_id;
  final String first_name;
  final String last_name;
  final LatLng? currentLocation;
  final Function viewMap;
  final Function viewOrderHistory;
  final List<Order> orderHistory;
  final bool isLoading;

  const UserHomeContent({
    super.key,
    required this.email_id,
    required this.first_name,
    required this.last_name,
    required this.currentLocation,
    required this.viewMap,
    required this.viewOrderHistory,
    required this.orderHistory,
    required this.isLoading,
  });

  @override
  State<UserHomeContent> createState() => _UserHomeContentState();
}

class _UserHomeContentState extends State<UserHomeContent> {
  int _selectedFuelIndex = -1;
  int _selectedQuantity = 1;
  bool _showQuantitySelector = false;

  final List<FuelType> _fuelTypes = [
    FuelType(name: 'Petrol', price: 102.50, icon: Icons.local_gas_station, color: Colors.green),
    FuelType(name: 'Diesel', price: 89.75, icon: Icons.local_shipping, color: Colors.blue),
    FuelType(name: 'Premium', price: 115.20, icon: Icons.star, color: Colors.purple),
  ];

  final api = Api();

  void _selectFuelType(int index) {
    setState(() {
      _selectedFuelIndex = index;
      _showQuantitySelector = true;
      _selectedQuantity = 1;
    });
  }

  Future<void> _placeOrder() async {
    if (widget.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available!")),
      );
      return;
    }

    try {
      await api.placeOrder(
        email: widget.email_id,
        fuelType: _fuelTypes[_selectedFuelIndex].name,
        amount: (_fuelTypes[_selectedFuelIndex].price * _selectedQuantity).toInt(),
        lat: widget.currentLocation!.latitude.toString(),
        long: widget.currentLocation!.longitude.toString(),
        quantity: _selectedQuantity, pumpId: '',
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to place order"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.first_name.isNotEmpty ? '${widget.first_name} ' : ''}${widget.last_name.isNotEmpty ? widget.last_name : 'User'}",
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
                      child: widget.currentLocation != null
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
                      onPressed: () => widget.viewMap(),
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
              ],
            ),
          ),

          // Rest of your home content...
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Select Fuel Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            color: _selectedQuantity == quantity
                                ? _fuelTypes[_selectedFuelIndex].color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedQuantity == quantity
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
                                color: _selectedQuantity == quantity
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
              onPressed: _selectedFuelIndex >= 0 && !widget.isLoading ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
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
                    if (widget.orderHistory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${widget.orderHistory.length}",
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
                  onPressed: () => widget.viewOrderHistory(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.orderHistory.isEmpty
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
              itemCount: widget.orderHistory.length,
              itemBuilder: (context, index) {
                final order = widget.orderHistory[index];
                final fuelColor = _fuelTypes.firstWhere(
                      (type) => type.name == order.fuelType,
                  orElse: () => _fuelTypes[0],
                ).color;

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
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.2),
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
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: fuelType.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                fuelType.icon,
                size: 32,
                color: fuelType.color,
              ),
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
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