import 'package:flutter/material.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final VoidCallback onAssign;
  final VoidCallback onConfirm;

  const OrderListItem({
    Key? key,
    required this.order,
    required this.onAssign,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final formattedDate = DateFormat('dd MMM, hh:mm a').format(order.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Order #${order.id}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "${order.fuelType} • ${order.quantity}L • ₹${order.amount.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        Text(
          "Customer: ${order.customerName}",
          style: TextStyle(color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        Text(
          formattedDate,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        if (order.deliveryPartner != null) ...[
          SizedBox(height: 4),
          Text(
            "Assigned to: ${order.deliveryPartner}",
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
        SizedBox(height: 12),
        if (order.status == "Pending")
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Assign Delivery Partner"),
          ),
        if (order.status == "In Progress")
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Confirm Delivery"),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "in progress":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}