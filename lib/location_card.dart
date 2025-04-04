import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatelessWidget {
  final LatLng? currentLocation;
  final VoidCallback onRefresh;

  const LocationCard({
    Key? key,
    required this.currentLocation,
    required this.onRefresh,
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
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (currentLocation != null)
              Text(
                "Lat: ${currentLocation!.latitude.toStringAsFixed(6)}\nLng: ${currentLocation!.longitude.toStringAsFixed(6)}",
                style: TextStyle(color: Colors.grey[700]),
              )
            else
              Text(
                "Location not available",
                style: TextStyle(color: Colors.grey[700]),
              ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh, size: 18),
              label: Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}