import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:roadassist/api.dart';

class PaymentScreen extends StatefulWidget {
  final String emailId;

  const PaymentScreen({super.key, required this.emailId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final api = Api();
  bool isLoading = false;
  String errorMessage = '';
  String selectedPaymentMethod = 'ICICI_UPI';
  bool _paymentSuccess = false;
  final TextEditingController _amountController = TextEditingController();
  double _amount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _paymentSuccess
          ? _buildPaymentSuccess()
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAmountInput(),
              if (_amount > 0) ...[
                const SizedBox(height: 24),
                _buildAmountCard(),
              ],
              const SizedBox(height: 24),
              _buildPreferredMethods(),
              const SizedBox(height: 24),
              _buildAllPaymentMethods(),
              const SizedBox(height: 24),
              if (_amount > 0) _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Gateway',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green[800], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Secure',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildAmountInput() {
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
            'Enter Amount (₹)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              prefixIcon: const Icon(Icons.currency_rupee),
              suffixIcon: _amountController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _amountController.clear();
                  setState(() {
                    _amount = 0.0;
                  });
                },
              )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickAmountButton(100),
              _buildQuickAmountButton(200),
              _buildQuickAmountButton(500),
              _buildQuickAmountButton(1000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: Colors.blue[800]!),
      ),
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(2);
        setState(() {
          _amount = amount;
        });
      },
      child: Text(
        '₹$amount',
        style: TextStyle(
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount to pay',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${_amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const LinearProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.grey,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          const Text(
            'Transaction secured by Razorpay',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          title: 'ICICI Bank - UPI',
          subtitle: 'xxxx 4411',
          trailing: '5% CASHBACK',
          icon: Icons.account_balance,
          iconColor: Colors.purple,
          isSelected: selectedPaymentMethod == 'ICICI_UPI',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'ICICI_UPI';
            });
          },
        ),
        _buildPaymentOption(
          title: 'ICICI Bank - Netbanking',
          subtitle: 'Instant payment',
          icon: Icons.account_balance,
          iconColor: Colors.purple,
          isSelected: selectedPaymentMethod == 'ICICI_NETBANKING',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'ICICI_NETBANKING';
            });
          },
        ),
      ],
    );
  }

  Widget _buildAllPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Payment Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          title: 'UPI',
          subtitle: 'Pay with any UPI app',
          icon: Icons.payment,
          iconColor: Colors.blue,
          isSelected: selectedPaymentMethod == 'UPI',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'UPI';
            });
          },
        ),
        _buildPaymentOption(
          title: 'Google Pay',
          subtitle: 'Fast & Secure',
          icon: Icons.payment,
          iconColor: Colors.blue,
          isSelected: selectedPaymentMethod == 'GOOGLE_PAY',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'GOOGLE_PAY';
            });
          },
        ),
        _buildPaymentOption(
          title: 'PhonePe',
          subtitle: 'Instant payment',
          icon: Icons.payment,
          iconColor: Colors.blue,
          isSelected: selectedPaymentMethod == 'PHONEPE',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'PHONEPE';
            });
          },
        ),
        _buildPaymentOption(
          title: 'Credit/Debit Card',
          subtitle: 'All cards accepted',
          icon: Icons.credit_card,
          iconColor: Colors.orange,
          isSelected: selectedPaymentMethod == 'CREDIT_CARD',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'CREDIT_CARD';
            });
          },
        ),
        _buildPaymentOption(
          title: 'Net Banking',
          subtitle: 'All Indian banks',
          icon: Icons.account_balance,
          iconColor: Colors.blue,
          isSelected: selectedPaymentMethod == 'NETBANKING',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'NETBANKING';
            });
          },
        ),
        _buildPaymentOption(
          title: 'Wallet',
          subtitle: 'Paytm, Mobikwik & more',
          icon: Icons.wallet,
          iconColor: Colors.teal,
          isSelected: selectedPaymentMethod == 'WALLET',
          onTap: () {
            setState(() {
              selectedPaymentMethod = 'WALLET';
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    String? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.1),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50]?.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? iconColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? iconColor : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trailing,
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () async {
          if (selectedPaymentMethod.contains('UPI')) {
            // Navigate to UPI pin page
            final success = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpiPinPage(
                  amount: _amount,
                  bankName: selectedPaymentMethod.contains('ICICI') ? 'ICICI Bank' : 'Axis Bank',
                  lastFourDigits: '5286',
                  emailId: widget.emailId, // Pass emailId to UpiPinPage
                ),
              ),
            );

            if (success == true) {
              await _updateBalance(_amount);
              setState(() {
                _paymentSuccess = true;
              });
            }
            return;
          }

          setState(() {
            isLoading = true;
          });

          try {
            // Simulate payment processing
            await Future.delayed(const Duration(seconds: 2));
            await _updateBalance(_amount);

            setState(() {
              isLoading = false;
              _paymentSuccess = true;
            });
          } catch (e) {
            setState(() {
              isLoading = false;
              errorMessage = 'Payment failed: $e';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        },
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Continue to Payment',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '₹${_amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction ID: RA${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _updateBalance(double amount) async {
    try {
      final response = await api.updateBalance(
        amount: amount,
        email_id: widget.emailId,
      );

      // You can show a success message if needed
      debugPrint('Balance updated: ${response.body}');
    } catch (e) {
      debugPrint('Error updating balance: $e');
      // Even if API fails, we consider payment successful in UI
      // but you might want to handle this differently
    }
  }
}

class UpiPinPage extends StatefulWidget {
  final double amount;
  final String bankName;
  final String lastFourDigits;

  const UpiPinPage({
    super.key,
    required this.amount,
    required this.bankName,
    required this.lastFourDigits, required String emailId,
  });

  @override
  State<UpiPinPage> createState() => _UpiPinPageState();
}

class _UpiPinPageState extends State<UpiPinPage> {
  String _enteredPin = '';
  bool _showPin = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Enter UPI PIN'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildBankInfo(),
                  const SizedBox(height: 40),
                  _buildPinDisplay(),
                  const SizedBox(height: 40),
                  _buildNumpad(),
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildBankInfo() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.blue[800],
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.bankName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'XXXX XXXX XXXX ${widget.lastFourDigits}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Column(
      children: [
        Text(
          'ENTER UPI PIN',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 4; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _enteredPin.length
                      ? _showPin
                      ? Colors.transparent
                      : Colors.blue[800]
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: i < _enteredPin.length && _showPin
                    ? Center(
                  child: Text(
                    _enteredPin[i],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showPin = !_showPin;
            });
          },
          child: Text(
            _showPin ? 'HIDE PIN' : 'SHOW PIN',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: [
        for (int i = 1; i <= 9; i++)
          _buildNumButton(
            i.toString(),
            onPressed: () {
              if (_enteredPin.length < 4) {
                setState(() {
                  _enteredPin += i.toString();
                });
              }
            },
          ),
        const SizedBox(), // Empty cell
        _buildNumButton(
          '0',
          onPressed: () {
            if (_enteredPin.length < 4) {
              setState(() {
                _enteredPin += '0';
              });
            }
          },
        ),
        _buildNumButton(
          Icons.backspace,
          isIcon: true,
          onPressed: () {
            if (_enteredPin.isNotEmpty) {
              setState(() {
                _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildNumButton(
      dynamic content, {
        bool isIcon = false,
        VoidCallback? onPressed,
      }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Center(
            child: isIcon
                ? Icon(
              content as IconData,
              color: Colors.grey[700],
              size: 24,
            )
                : Text(
              content as String,
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _enteredPin.length == 4 ? Colors.blue[800] : Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: _enteredPin.length == 4
              ? () async {
            setState(() {
              _isProcessing = true;
            });
            // Simulate verification
            await Future.delayed(const Duration(milliseconds: 800));
            Navigator.pop(context, true);
          }
              : null,
          child: _isProcessing
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'PAY NOW',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }



}