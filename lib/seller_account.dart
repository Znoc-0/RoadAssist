import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roadassist/api.dart';
import 'package:roadassist/homeSeller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellerAccountScreen extends StatefulWidget {
  final String emailId;

  const SellerAccountScreen({Key? key, required this.emailId}) : super(key: key);

  @override
  State<SellerAccountScreen> createState() => _SellerAccountScreenState();
}

class _SellerAccountScreenState extends State<SellerAccountScreen> {
  final api = Api();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _sellerInfo;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSellerInfo();
  }

  Future<void> _fetchSellerInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await api.getCurrentSeller(email_id: widget.emailId);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sellerInfo = data['seller'];
          _balance = _sellerInfo?['balance']?.toDouble() ?? 0.0;
        });
      } else {
        throw Exception('Failed to load seller data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _fetchSellerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Seller Account'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Profile Section
              _buildBusinessProfileSection(),
              const SizedBox(height: 24),

              // Credit Card Wallet
              _buildCreditCardWallet(),
              const SizedBox(height: 16),

              // Transactions Button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     onPressed: _showTransactions,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue[800],
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     icon: const Icon(Icons.history, color: Colors.white),
              //     label: const Text(
              //       'View Transactions',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 24),

              // Business Details Section
              _buildBusinessDetailsSection(),
              const SizedBox(height: 24),

              // Action Buttons

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardWallet() {
    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card chip
              Positioned(
                top: 30,
                left: 25,
                child: Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF9D423), Color(0xFFE65C00)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.credit_card,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Card number
              Positioned(
                top: 80,
                left: 25,
                right: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                        (index) => Text(
                      '••••',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Available Balance
              Positioned(
                top: 30,
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'AVAILABLE BALANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Business name
              Positioned(
                bottom: 70,
                left: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUSINESS NAME',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 200,
                      child: Text(
                        '${_sellerInfo?['pump_name'] ?? 'FUEL STATION'}'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Expiry date
              Positioned(
                bottom: 70,
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VALID THRU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '12/25',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Bank logo
              Positioned(
                bottom: 25,
                left: 25,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/196/196578.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
            ),
            child: Icon(Icons.business, size: 30, color: Colors.blue[800]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sellerInfo?['pump_name'] ?? 'Fuel Station',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_sellerInfo?['rating'] ?? '0.0'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBusinessDetailsSection() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final registrationDate = _sellerInfo?['registration_date'] != null
        ? dateFormat.format(DateTime.parse(_sellerInfo!['registration_date']))
        : 'Not available';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.phone,
            'Phone',
            _sellerInfo?['phone'] ?? 'Not provided',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.email,
            'Email',
            _sellerInfo?['email'] ?? widget.emailId,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.location_city,
            'Address',
            _sellerInfo?['address'] ?? 'Not provided',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.calendar_today,
            'Registration Date',
            registrationDate,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.person,
            'Owner Name',
            _sellerInfo?['owner_name'] ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue[800]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  void _showTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _sellerInfo?['transactions'] == null || (_sellerInfo!['transactions'] as List).isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.builder(
                  itemCount: (_sellerInfo!['transactions'] as List).length,
                  itemBuilder: (context, index) {
                    final transaction = _sellerInfo!['transactions'][index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: transaction['type'] == 'credit'
                                ? Colors.green[100]
                                : Colors.red[100],
                          ),
                          child: Icon(
                            transaction['type'] == 'credit'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: transaction['type'] == 'credit'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(
                          transaction['type'] == 'credit' ? 'Credit' : 'Debit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaction['type'] == 'credit'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        subtitle: Text(transaction['date'] ?? 'Unknown date'),
                        trailing: Text(
                          '₹${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: transaction['type'] == 'credit'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Delete account logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}