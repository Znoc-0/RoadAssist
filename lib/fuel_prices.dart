import 'package:flutter/material.dart';
import 'models.dart';

class FuelPricesCard extends StatelessWidget {
  final FuelPrices prices;
  final VoidCallback onEditPressed;

  const FuelPricesCard({
    Key? key,
    required this.prices,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_gas_station, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Fuel Prices",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: onEditPressed,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceChip("Petrol", prices.petrol, Colors.green),
                _buildPriceChip("Diesel", prices.diesel, Colors.blue),
                _buildPriceChip("Premium", prices.premium, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String fuelType, double price, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            fuelType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "₹${price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}