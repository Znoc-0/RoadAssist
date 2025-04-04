import 'package:flutter/material.dart';
import 'map.dart';
import 'api.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final Api api = Api();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Show Terms & Conditions popup
    bool? agreed = await _showTermsDialog();
    if (agreed != true) return; // If not agreed, stop here

    setState(() => _isLoading = true);

    try {
      await api.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showTermsDialog() async {
    bool agreedToAll = false; // Single checkbox state
    final List<String> terms = [
      "I will not use this service for any illegal activities.",
      "I understand that fuel delivery is prohibited in restricted areas.",
      "I will ensure my vehicle is parked safely for refueling.",
      "I acknowledge that only authorized personnel handle fuel.",
      "I will not attempt to store, transfer, or resell fuel.",
      "I agree that payment must be completed before confirmation.",
      "I understand misuse may result in suspension or legal action.",
      "I will report fraudulent activities or safety concerns.",
      "I acknowledge the company isn't responsible for negligence damages.",
      "I will comply with local fuel regulations.",
    ];

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                "Terms & Conditions",
                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...terms.map((term) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "• $term",
                        style: const TextStyle(fontSize: 14),
                      ),
                    )),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: const Text(
                        "I Agree to All Terms & Conditions",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: agreedToAll,
                      onChanged: (value) {
                        setDialogState(() {
                          agreedToAll = value ?? false;
                        });
                      },
                      activeColor: Colors.blue[700],
                      dense: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Cancel
                  child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: agreedToAll
                      ? () => Navigator.pop(context, true) // Agree
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("AGREE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Fill in your details to get started",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person),
                    const SizedBox(height: 24),
                    _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('CONFIRM',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
      ),
      validator: (value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null,
    );
  }
}