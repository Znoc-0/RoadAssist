import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class WorkshopPage extends StatefulWidget {
  final String emailId;

  const WorkshopPage({Key? key, required this.emailId}) : super(key: key);

  @override
  _WorkshopPageState createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  final List<Workshop> _workshops = [];
  Workshop? _selectedWorkshop;

  // 25 dummy workshops in Pathanamthitta and nearby areas
  final List<Workshop> _keralaWorkshops = [
    Workshop(
      id: '1',
      name: 'Pathanamthitta Auto Care',
      location: LatLng(9.2649, 76.7870),
      address: 'MC Road, Pathanamthitta',
      services: ['Oil Change', 'Brake Repair', 'Wheel Alignment'],
      contact: '04682345678',
      rating: 4.3,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '2',
      name: 'Ranni Motor Works',
      location: LatLng(9.3847, 76.8081),
      address: 'Near Ranni Bus Stand, Pathanamthitta',
      services: ['AC Service', 'Battery Replacement', 'Tire Change'],
      contact: '04735234567',
      rating: 4.1,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '3',
      name: 'Konni Auto Tech',
      location: LatLng(9.2376, 76.8614),
      address: 'Konni-Pathanamthitta Road',
      services: ['Engine Tuning', 'Denting', 'Painting'],
      contact: '04736234567',
      rating: 4.4,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '4',
      name: 'Adoor Precision Motors',
      location: LatLng(9.1559, 76.7319),
      address: 'NH 183, Adoor',
      services: ['Transmission Repair', 'Electrical Works', 'Suspension'],
      contact: '04734234567',
      rating: 4.6,
      distance: 0,
      isOpen: false,
    ),
    Workshop(
      id: '5',
      name: 'Thiruvalla Auto Service',
      location: LatLng(9.3833, 76.5667),
      address: 'Church Road, Thiruvalla',
      services: ['Full Service', 'Computer Diagnostics', 'AC Repair'],
      contact: '04692345678',
      rating: 4.5,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '6',
      name: 'Kozhencherry Car Clinic',
      location: LatLng(9.3333, 76.7000),
      address: 'Kozhencherry Market Road',
      services: ['Oil Change', 'Brake Service', 'Wheel Balancing'],
      contact: '04682345679',
      rating: 4.0,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '7',
      name: 'Mavelikara Auto Works',
      location: LatLng(9.2667, 76.5500),
      address: 'Mavelikara Town',
      services: ['Denting', 'Painting', 'Rust Proofing'],
      contact: '04792345678',
      rating: 4.2,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '8',
      name: 'Chengannur Quick Fix',
      location: LatLng(9.3167, 76.6167),
      address: 'Chengannur Bypass Road',
      services: ['Tire Change', 'Battery Jumpstart', '24/7 Assistance'],
      contact: '04792345679',
      rating: 4.7,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '9',
      name: 'Pandalam Auto Garage',
      location: LatLng(9.3167, 76.6833),
      address: 'Pandalam Main Road',
      services: ['General Repair', 'Electrical', 'AC Service'],
      contact: '04735234568',
      rating: 3.9,
      distance: 0,
      isOpen: false,
    ),
    Workshop(
      id: '10',
      name: 'Elanthoor Vehicle Care',
      location: LatLng(9.3000, 76.7500),
      address: 'Elanthoor-Pathanamthitta Road',
      services: ['Oil Change', 'Filter Replacement', 'Car Wash'],
      contact: '04682345680',
      rating: 4.1,
      distance: 0,
      isOpen: true,
    ),
    // Additional workshops in nearby districts
    Workshop(
      id: '11',
      name: 'Kottayam Auto Experts',
      location: LatLng(9.5916, 76.5222),
      address: 'KK Road, Kottayam',
      services: ['Engine Overhaul', 'Transmission', 'Differential'],
      contact: '04812345678',
      rating: 4.8,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '12',
      name: 'Alappuzha Car Hospital',
      location: LatLng(9.4980, 76.3388),
      address: 'NH 66, Alappuzha',
      services: ['AC Repair', 'Electrical', 'Computer Diagnostics'],
      contact: '04772345678',
      rating: 4.4,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '13',
      name: 'Ernakulam Auto Tech',
      location: LatLng(9.9312, 76.2673),
      address: 'Marine Drive, Kochi',
      services: ['Luxury Car Service', 'Hybrid/Electric', 'Detailing'],
      contact: '04842345678',
      rating: 4.9,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '14',
      name: 'Idukki Hill Auto',
      location: LatLng(9.8497, 76.9720),
      address: 'Thodupuzha Main Road',
      services: ['4x4 Service', 'Suspension', 'Off-road Modifications'],
      contact: '04862345678',
      rating: 4.3,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '15',
      name: 'Kollam Quick Service',
      location: LatLng(8.8932, 76.6141),
      address: 'Chinnakada, Kollam',
      services: ['Quick Repairs', 'Tire Service', 'Battery'],
      contact: '04742345678',
      rating: 4.0,
      distance: 0,
      isOpen: false,
    ),
    Workshop(
      id: '16',
      name: 'Trivandrum Auto Masters',
      location: LatLng(8.5241, 76.9366),
      address: 'MG Road, Thiruvananthapuram',
      services: ['Complete Overhaul', 'Painting', 'Custom Works'],
      contact: '04712345678',
      rating: 4.7,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '17',
      name: 'Angamaly Auto Care',
      location: LatLng(10.1966, 76.3870),
      address: 'NH 544, Angamaly',
      services: ['General Service', 'AC Repair', 'Electrical'],
      contact: '04842345679',
      rating: 4.2,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '18',
      name: 'Perumbavoor Vehicle Solutions',
      location: LatLng(10.1159, 76.4768),
      address: 'Muvattupuzha-Perumbavoor Road',
      services: ['Truck Repair', 'Bus Service', 'Commercial Vehicles'],
      contact: '04842345680',
      rating: 4.5,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '19',
      name: 'Muvattupuzha Auto Garage',
      location: LatLng(9.9667, 76.5833),
      address: 'Kothamangalam Road',
      services: ['General Repair', 'Denting', 'Painting'],
      contact: '04852345678',
      rating: 4.1,
      distance: 0,
      isOpen: false,
    ),
    Workshop(
      id: '20',
      name: 'Pala Auto Works',
      location: LatLng(9.7167, 76.6833),
      address: 'Pala-Kottayam Road',
      services: ['Electrical Works', 'AC Service', 'Engine Tuning'],
      contact: '04822234567',
      rating: 4.3,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '21',
      name: 'Changanassery Car Care',
      location: LatLng(9.4500, 76.5333),
      address: 'MC Road, Changanassery',
      services: ['Computer Diagnostics', 'Service Packages', 'AC Repair'],
      contact: '04812345679',
      rating: 4.6,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '22',
      name: 'Kattappana Auto Tech',
      location: LatLng(9.7500, 77.0833),
      address: 'Kumily Road, Kattappana',
      services: ['General Repair', 'Tire Service', 'Battery'],
      contact: '04862234567',
      rating: 4.0,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '23',
      name: 'Nedumkandam Vehicle Point',
      location: LatLng(9.8500, 77.1500),
      address: 'Nedumkandam Market',
      services: ['Oil Change', 'Brake Service', 'Wheel Alignment'],
      contact: '04862234568',
      rating: 3.9,
      distance: 0,
      isOpen: false,
    ),
    Workshop(
      id: '24',
      name: 'Thodupuzha Auto Solutions',
      location: LatLng(9.9000, 76.7167),
      address: 'Munnar Road, Thodupuzha',
      services: ['Engine Repair', 'Transmission', 'Suspension'],
      contact: '04862345679',
      rating: 4.4,
      distance: 0,
      isOpen: true,
    ),
    Workshop(
      id: '25',
      name: 'Kottarakkara Auto Garage',
      location: LatLng(9.0000, 76.7667),
      address: 'Kottarakkara-Punalur Road',
      services: ['General Service', 'Denting', 'Painting'],
      contact: '04742345679',
      rating: 4.2,
      distance: 0,
      isOpen: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await location.getLocation();
    setState(() {
      _currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      _calculateDistances();
      _isLoading = false;
    });
  }

  void _calculateDistances() {
    if (_currentPosition == null) return;

    setState(() {
      _workshops.clear();
      for (var workshop in _keralaWorkshops) {
        final distance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          workshop.location.latitude,
          workshop.location.longitude,
        );
        _workshops.add(workshop.copyWith(distance: distance));
      }
      _workshops.sort((a, b) => a.distance.compareTo(b.distance));
    });
  }

  double _calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
            cos((lat2 - lat1) * p) / 2 +
            cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onWorkshopSelected(Workshop workshop) {
    setState(() {
      _selectedWorkshop = workshop;
    });
    mapController.animateCamera(CameraUpdate.newLatLng(workshop.location));
  }

  Future<void> _launchMapsDirections(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _callWorkshop(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Find Workshops',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Hello, ${widget.emailId.split('@')[0]}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                ),
              ],
            ),
          ),

          // Map Section
          Container(
            height: 250,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? _keralaWorkshops[0].location,
                  zoom: 12,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: _buildMarkers(),
              ),
            ),
          ),

          // Workshop Details Card
          if (_selectedWorkshop != null) _buildWorkshopDetailsCard(),

          // List Header
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Workshops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_workshops.length} nearby',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Workshops List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _workshops.length,
              itemBuilder: (context, index) {
                final workshop = _workshops[index];
                return _buildWorkshopListItem(workshop);
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _workshops.map((workshop) {
      return Marker(
        markerId: MarkerId(workshop.id),
        position: workshop.location,
        infoWindow: InfoWindow(
          title: workshop.name,
          snippet: '${workshop.distance.toStringAsFixed(1)} km away',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          workshop.isOpen ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
        ),
        onTap: () => _onWorkshopSelected(workshop),
      );
    }).toSet();
  }

  Widget _buildWorkshopDetailsCard() {
    if (_selectedWorkshop == null) return Container();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedWorkshop!.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedWorkshop!.isOpen
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedWorkshop!.isOpen ? 'OPEN NOW' : 'CLOSED',
                  style: TextStyle(
                    color: _selectedWorkshop!.isOpen ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  _selectedWorkshop!.address,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWorkshop!.services.map((service) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.directions, size: 18),
                  label: Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[800], side: BorderSide(color: Colors.blue[300]!),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      _launchMapsDirections(_selectedWorkshop!.location),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.phone, size: 18),
                  label: Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _callWorkshop(_selectedWorkshop!.contact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopListItem(Workshop workshop) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onWorkshopSelected(workshop),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.car_repair,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${workshop.distance.toStringAsFixed(1)} km • ${workshop.services.take(2).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        workshop.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${workshop.contact}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
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
}

class Workshop {
  final String id;
  final String name;
  final LatLng location;
  final String address;
  final List<String> services;
  final String contact;
  final double rating;
  final double distance;
  final bool isOpen;

  Workshop({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.services,
    required this.contact,
    required this.rating,
    required this.distance,
    required this.isOpen,
  });

  Workshop copyWith({
    String? id,
    String? name,
    LatLng? location,
    String? address,
    List<String>? services,
    String? contact,
    double? rating,
    double? distance,
    bool? isOpen,
  }) {
    return Workshop(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      services: services ?? this.services,
      contact: contact ?? this.contact,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}