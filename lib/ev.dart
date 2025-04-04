import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class EVStationsPage extends StatefulWidget {
  final String emailId;

  const EVStationsPage({Key? key, required this.emailId}) : super(key: key);

  @override
  _EVStationsPageState createState() => _EVStationsPageState();
}

class _EVStationsPageState extends State<EVStationsPage> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  final List<EVStation> _evStations = [];
  EVStation? _selectedStation;

  // Sample EV stations in Kerala (you can replace with real API data)
  final List<EVStation> _keralaEVStations = [
    EVStation(
      id: '1',
      name: 'Tata Power EV Station',
      location: LatLng(8.5241, 76.9366), // Trivandrum
      address: 'MG Road, Thiruvananthapuram',
      availablePorts: 4,
      powerOutput: '50 kW',
      distance: 0,
    ),

  EVStation(
  id: '1',
  name: 'KSEB EV Charging Station',
  location: LatLng(9.2648, 76.7870), // Pathanamthitta Town
  address: 'Near KSEB Office, Pathanamthitta',
  availablePorts: 2,
  powerOutput: '30 kW',
  distance: 0,
  ),
  EVStation(
  id: '2',
  name: 'Tata Power EV Station',
  location: LatLng(9.2589, 76.7785), // Thiruvalla
  address: 'KSRTC Bus Stand, Thiruvalla',
  availablePorts: 3,
  powerOutput: '50 kW',
  distance: 0,
  ),
  EVStation(
  id: '3',
  name: 'KSEB EV Charging Point',
  location: LatLng(9.3806, 76.5747), // Adoor
  address: 'Adoor Town, Pathanamthitta',
  availablePorts: 2,
  powerOutput: '15 kW',
  distance: 0,
  ),
  EVStation(
  id: '4',
  name: 'BPCL EV Station',
  location: LatLng(8.8932, 76.6141), // Kollam Town
  address: 'BPCL Fuel Station, Kollam',
  availablePorts: 2,
  powerOutput: '30 kW',
  distance: 0,
  ),
  EVStation(
  id: '5',
  name: 'KSEB EV Charging',
  location: LatLng(8.8801, 76.5917), // Asramam
  address: 'Asramam Ground, Kollam',
  availablePorts: 2,
  powerOutput: '22 kW',
  distance: 0,
  ),
  EVStation(
  id: '6',
  name: 'Tata Power EV Charger',
  location: LatLng(8.9015, 76.5954), // Chinnakada
  address: 'Near Chinnakada Circle, Kollam',
  availablePorts: 4,
  powerOutput: '50 kW',
  distance: 0,
  ),
  EVStation(
  id: '7',
  name: 'KSEB EV Point',
  location: LatLng(9.4905, 76.3294), // Chengannur
  address: 'Chengannur Town, Alappuzha',
  availablePorts: 2,
  powerOutput: '15 kW',
  distance: 0,
  ),
  EVStation(
  id: '8',
  name: 'BPCL EV Charging',
  location: LatLng(9.4901, 76.3380), // Chengannur
  address: 'BPCL Pump, Chengannur',
  availablePorts: 2,
  powerOutput: '30 kW',
  distance: 0,
  ),
  EVStation(
  id: '9',
  name: 'KSEB EV Station',
  location: LatLng(9.3188, 76.4075), // Mavelikara
  address: 'Mavelikara Town, Alappuzha',
  availablePorts: 2,
  powerOutput: '22 kW',
  distance: 0,
  ),
  EVStation(
  id: '10',
  name: 'Tata Power EV Charging',
  location: LatLng(9.4900, 76.3380), // Haripad
  address: 'Haripad Town, Alappuzha',
  availablePorts: 3,
  powerOutput: '50 kW',
  distance: 0,
  ),
  EVStation(
  id: '11',
  name: 'KSEB EV Charger',
  location: LatLng(9.1380, 76.7320), // Kayamkulam
  address: 'Near Kayamkulam Bus Stand',
  availablePorts: 2,
  powerOutput: '15 kW',
  distance: 0,
  ),
  EVStation(
  id: '12',
  name: 'BPCL EV Point',
  location: LatLng(9.1390, 76.7310), // Kayamkulam
  address: 'BPCL Fuel Station, Kayamkulam',
  availablePorts: 2,
  powerOutput: '30 kW',
  distance: 0,
  ),
  EVStation(
  id: '13',
  name: 'KSEB EV Charging',
  location: LatLng(9.4905, 76.3380), // Ambalappuzha
  address: 'Ambalappuzha Town',
  availablePorts: 2,
  powerOutput: '22 kW',
  distance: 0,
  ),
  EVStation(
  id: '14',
  name: 'Tata Power EV Station',
  location: LatLng(9.4900, 76.3290), // Alappuzha Town
  address: 'Near Boat Jetty, Alappuzha',
  availablePorts: 4,
  powerOutput: '50 kW',
  distance: 0,
  ),
  EVStation(
  id: '15',
  name: 'KSEB EV Charging Point',
  location: LatLng(9.4920, 76.3400), // Cherthala
  address: 'Cherthala Town, Alappuzha',
  availablePorts: 2,
  powerOutput: '15 kW',
  distance: 0,
  ),
    EVStation(
      id: '2',
      name: 'KSEB EV Charging Point',
      location: LatLng(9.9312, 76.2673), // Kochi
      address: 'Marine Drive, Ernakulam',
      availablePorts: 2,
      powerOutput: '30 kW',
      distance: 0,
    ),
    EVStation(
      id: '3',
      name: 'Zeon Charging',
      location: LatLng(10.8505, 76.2711), // Palakkad
      address: 'NH 544, Palakkad',
      availablePorts: 3,
      powerOutput: '60 kW',
      distance: 0,
    ),
    EVStation(
      id: '4',
      name: 'Ather Grid',
      location: LatLng(11.2588, 75.7804), // Kozhikode
      address: 'Mavoor Road, Calicut',
      availablePorts: 2,
      powerOutput: '25 kW',
      distance: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();
    setState(() {
      _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      _calculateDistances();
      _isLoading = false;
    });
  }

  void _calculateDistances() {
    if (_currentPosition == null) return;

    setState(() {
      _evStations.clear();
      for (var station in _keralaEVStations) {
        final distance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          station.location.latitude,
          station.location.longitude,
        );
        _evStations.add(station.copyWith(distance: distance));
      }
      // Sort by distance
      _evStations.sort((a, b) => a.distance.compareTo(b.distance));
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2*R*asin...
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onStationSelected(EVStation station) {
    setState(() {
      _selectedStation = station;
    });
    mapController.animateCamera(
      CameraUpdate.newLatLng(station.location),
    );
  }

  Future<void> _launchMapsDirections(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header section (matching your existing UI)
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EV Stations in Kerala',
                      style: TextStyle(
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
                        // Navigate to account screen
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${widget.emailId}',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentPosition != null
                                  ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                  : 'Location not available',
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

          // Map and List View
          Expanded(
            child: Column(
              children: [
                // Map Section
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition ?? _keralaEVStations[0].location,
                      zoom: 10,
                    ),
                    myLocationEnabled: true,
                    markers: _buildMarkers(),
                  ),
                ),

                // Station Details Card
                if (_selectedStation != null) _buildStationDetailsCard(),

                // Stations List Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nearby Stations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '${_evStations.length} stations',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stations List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _evStations.length,
                    itemBuilder: (context, index) {
                      final station = _evStations[index];
                      return _buildStationListItem(station);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _evStations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: station.location,
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '${station.distance.toStringAsFixed(1)} km away',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          station.availablePorts > 0
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => _onStationSelected(station),
      );
    }).toSet();
  }

  Widget _buildStationDetailsCard() {
    if (_selectedStation == null) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedStation!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedStation!.availablePorts > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedStation!.availablePorts > 0 ? 'Available' : 'Busy',
                  style: TextStyle(
                    color: _selectedStation!.availablePorts > 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStation!.address,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailChip(
                icon: Icons.ev_station,
                label: '${_selectedStation!.availablePorts} ports',
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                icon: Icons.bolt,
                label: _selectedStation!.powerOutput,
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                icon: Icons.directions_car,
                label: '${_selectedStation!.distance.toStringAsFixed(1)} km',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () => _launchMapsDirections(_selectedStation!.location),
            child: const Text(
              'Get Directions',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.blue.shade800)),
        ],
      ),
    );
  }

  Widget _buildStationListItem(EVStation station) {
    return GestureDetector(
      onTap: () => _onStationSelected(station),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _selectedStation?.id == station.id
                ? Colors.blue
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.ev_station,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${station.distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${station.availablePorts} ports',
                  style: TextStyle(
                    fontSize: 12,
                    color: station.availablePorts > 0
                        ? Colors.green
                        : Colors.red,
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

class EVStation {
  final String id;
  final String name;
  final LatLng location;
  final String address;
  final int availablePorts;
  final String powerOutput;
  final double distance;

  EVStation({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.availablePorts,
    required this.powerOutput,
    required this.distance,
  });

  EVStation copyWith({
    String? id,
    String? name,
    LatLng? location,
    String? address,
    int? availablePorts,
    String? powerOutput,
    double? distance,
  }) {
    return EVStation(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      availablePorts: availablePorts ?? this.availablePorts,
      powerOutput: powerOutput ?? this.powerOutput,
      distance: distance ?? this.distance,
    );
  }
}