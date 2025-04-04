import 'package:flutter/material.dart';
import 'models.dart';

class DeliveryPartnersCard extends StatelessWidget {
  final List<DeliveryPartner> partners;
  final VoidCallback onManagePressed;

  const DeliveryPartnersCard({
    Key? key,
    required this.partners,
    required this.onManagePressed,
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
                    Icon(Icons.delivery_dining, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Delivery Partners",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onManagePressed,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text("Manage"),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (partners.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No delivery partners available",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: partners.length,
                separatorBuilder: (context, index) => Divider(height: 16),
                itemBuilder: (context, index) {
                  final partner = partners[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(
                      partner.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(partner.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                partner.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(partner.status),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              partner.rating.toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone, color: Colors.blue),
                      onPressed: () {
                        // Call delivery partner
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "available":
        return Colors.green;
      case "on delivery":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}