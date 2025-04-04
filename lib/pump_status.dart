import 'package:flutter/material.dart';
import 'models.dart';

class PumpStatusCard extends StatelessWidget {
  final PumpDetails? pumpDetails;
  final bool isOpen;
  final ValueChanged<bool> onStatusChanged;

  const PumpStatusCard({
    Key? key,
    required this.pumpDetails,
    required this.isOpen,
    required this.onStatusChanged,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pumpDetails?.name ?? "Fuel Pump",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    pumpDetails?.address ?? "Address not available",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        "${pumpDetails?.rating ?? 0.0}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.phone, color: Colors.blue, size: 20),
                      SizedBox(width: 4),
                      Text(
                        pumpDetails?.phone ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOpen ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    isOpen ? "OPEN" : "CLOSED",
                    style: TextStyle(
                      color: isOpen ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isOpen,
                    onChanged: onStatusChanged,
                    activeColor: Colors.green,
                    activeTrackColor: Colors.green[200],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}