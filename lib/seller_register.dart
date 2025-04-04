import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roadassist/api.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {

  final api = Api();
  final _formKey = GlobalKey<FormState>();
  final _pumpNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isOver18 = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _pumpNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
  void _registerSeller() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isOver18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 18 years old to register')),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location for your pump')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the API function
      final response = await api.registerSeller(
        pumpName: _pumpNameController.text,
        Name: _ownerNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        age: int.parse(_ageController.text), // Ensure correct data type
        lat: _selectedLocation!.latitude.toString(),
        long: _selectedLocation!.longitude.toString(),
        username: _usernameController.text,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );

        // Navigate back or reset form
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Future<void> _selectLocation() async {
    LatLng? selectedLocation = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: false,
      isDismissible: false, // Prevents closing by tapping outside
      enableDrag: false,
      builder: (context) {
        LatLng? tempLocation = _selectedLocation; // Temporary location storage
        Set<Marker> tempMarkers = Set.from(_markers); // Copy of markers

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Pump Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: tempLocation ?? const LatLng(9.2648,76.7870),
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _mapController ??= controller;
                        if (tempLocation != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(tempLocation!),
                          );
                        }
                      },
                      onTap: (LatLng location) {
                        setModalState(() {
                          tempLocation = location;
                          tempMarkers.clear(); // Remove previous marker
                          tempMarkers.add(Marker(
                            markerId: const MarkerId('selected_location'),
                            position: location,
                            infoWindow: const InfoWindow(title: 'Pump Location'),
                          ));
                        });

                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(location),
                        );
                      },
                      markers: tempMarkers,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (tempLocation != null) {
                            Navigator.pop(context, tempLocation);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a location on the map'),
                              ),
                            );
                          }
                        },
                        child: const Text('Confirm Location'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation,
          infoWindow: const InfoWindow(title: 'Pump Location'),
        ));
      });
      print('Selected Location: Latitude ${selectedLocation.latitude}, Longitude ${selectedLocation.longitude}');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Seller Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTextField(
                controller: _pumpNameController,
                label: 'Pump Name',
                icon: Icons.local_gas_station,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pump name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter owner name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _isOver18,
                      onChanged: (value) {
                        setState(() {
                          _isOver18 = value ?? false;
                        });
                      },
                    ),
                    const Text('18+'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  if (value.length < 4) {
                    return 'Username must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _selectLocation,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: Text(
                  _selectedLocation == null
                      ? 'Select Pump Location'
                      : 'Location Selected (Tap to change)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.white, // White text for better contrast
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Sexy blue color
                  foregroundColor: Colors.white, // Ensures icon and text remain white
                  minimumSize: const Size(double.infinity, 50), // Full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Smooth rounded corners
                  ),
                  elevation: 4, // Subtle shadow for a modern look
                  padding: const EdgeInsets.symmetric(vertical: 14), // Better touch area
                ),
              )
              ,
              if (_selectedLocation != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                      '${_selectedLocation!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerSeller,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Sexy blue color
                    foregroundColor: Colors.white, // White text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Smooth rounded corners
                    ),
                    elevation: 4, // Subtle shadow effect
                    padding: const EdgeInsets.symmetric(vertical: 14), // Better touch area
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
              ,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}