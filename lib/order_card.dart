import 'package:flutter/material.dart';
import 'models.dart';
import 'order_list_item.dart';

class OrdersCard extends StatelessWidget {
  final List<Order> orders;
  final Function(String) onAssignPartner;
  final Function(String) onConfirmDelivery;
  final VoidCallback onViewAllPressed;

  const OrdersCard({
    Key? key,
    required this.orders,
    required this.onAssignPartner,
    required this.onConfirmDelivery,
    required this.onViewAllPressed,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Recent Orders",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onViewAllPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text("View All"),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No orders yet",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) => Divider(height: 16),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderListItem(
                    order: order,
                    onAssign: () => onAssignPartner(order.id),
                    onConfirm: () => onConfirmDelivery(order.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}