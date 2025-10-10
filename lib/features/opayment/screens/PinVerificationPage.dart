import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'TransactionReceiptPage.dart';

class PinVerificationPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String phoneNumber;
  final String provider;

  const PinVerificationPage({
    super.key,
    required this.product,
    required this.phoneNumber,
    required this.provider,
  });

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  String _pin = '';
  String _confirmPin = '';
  final int _maxPinLength = 6;
  bool _isProcessing = false;
  bool _isLoading = true;
  
  // PIN states
  bool _hasExistingPin = false;
  bool _isCreatePinMode = false;
  bool _isConfirmPinMode = false;
  String? _userId;
  
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // Initialize page by checking PIN status
  Future<void> _initializePage() async {
    try {
      // Get user ID from ProfileController
      final profileController = Get.find<ProfileController>();
      
      if (profileController.userInfoModel?.id != null) {
        _userId = profileController.userInfoModel!.id.toString();
        print('User ID: $_userId');
        
        // Check if user has PIN
        final pinStatus = await _detectPin(_userId!);
        
        setState(() {
          _hasExistingPin = pinStatus['has_pin'] == true;
          _isCreatePinMode = !_hasExistingPin;
          _isLoading = false;
        });
        
        print('Has existing PIN: $_hasExistingPin');
      } else {
        // No user ID available
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error', 'User tidak teridentifikasi. Silakan login ulang.');
      }
    } catch (e) {
      print('Initialize error: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error', 'Gagal memuat data user.');
    }
  }

  // API call to detect PIN
  Future<Map<String, dynamic>> _detectPin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/pin/detect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      print('PIN Detection Response: ${response.statusCode}');
      print('PIN Detection Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'has_pin': false};
      }
    } catch (e) {
      print('PIN Detection Error: $e');
      return {'success': false, 'has_pin': false};
    }
  }

  // API call to create PIN
  Future<Map<String, dynamic>> _createPin(String userId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/pin/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'pin': pin,
        }),
      );

      print('PIN Creation Response: ${response.statusCode}');
      print('PIN Creation Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to create PIN'
        };
      }
    } catch (e) {
      print('PIN Creation Error: $e');
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }

  // API call to verify PIN
  Future<Map<String, dynamic>> _verifyPin(String userId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/pin/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'pin': pin,
        }),
      );

      print('PIN Verification Response: ${response.statusCode}');
      print('PIN Verification Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'PIN verification failed',
          'failed_attempts': errorData['failed_attempts'],
          'locked_until': errorData['locked_until'],
          'attempts_remaining': errorData['attempts_remaining'],
        };
      }
    } catch (e) {
      print('PIN Verification Error: $e');
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }

  void _onNumberPressed(String number) {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      // Creating new PIN
      if (_pin.length < _maxPinLength) {
        setState(() {
          _pin += number;
        });
        
        if (_pin.length == _maxPinLength) {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _isConfirmPinMode = true;
            });
          });
        }
      }
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      // Confirming new PIN
      if (_confirmPin.length < _maxPinLength) {
        setState(() {
          _confirmPin += number;
        });
        
        if (_confirmPin.length == _maxPinLength) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _checkPinMatch();
          });
        }
      }
    } else {
      // Verifying existing PIN
      if (_pin.length < _maxPinLength) {
        setState(() {
          _pin += number;
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_isCreatePinMode && _isConfirmPinMode) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        });
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
      }
    }
  }

  void _checkPinMatch() {
    if (_pin == _confirmPin) {
      _handleCreatePin();
    } else {
      _showErrorDialog('PIN Tidak Cocok', 'PIN yang Anda masukkan tidak sama. Silakan coba lagi.');
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirmPinMode = false;
      });
    }
  }

  Future<void> _handleCreatePin() async {
    if (_userId == null) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _createPin(_userId!, _pin);

    if (result['success'] == true) {
      // PIN created successfully, now verify it and process payment
      _showSuccessDialog('PIN Berhasil Dibuat', 'PIN Anda telah berhasil dibuat. Transaksi akan dilanjutkan.', () {
        setState(() {
          _hasExistingPin = true;
          _isCreatePinMode = false;
          _isConfirmPinMode = false;
          _isProcessing = false;
        });
        _processPayment();
      });
    } else {
      setState(() {
        _isProcessing = false;
        _pin = '';
        _confirmPin = '';
        _isConfirmPinMode = false;
      });
      _showErrorDialog('Gagal Membuat PIN', result['error'] ?? 'Tidak dapat membuat PIN');
    }
  }

  String _generateRefId() {
    final random = Random();
    final randomNum = random.nextInt(999999).toString().padLeft(6, '0');
    return 'O-PAYMENT-$randomNum';
  }

  bool _isPascabayarTransaction() {
    return widget.product.containsKey('ref_id') && 
           widget.product['ref_id'] != null && 
           widget.product['ref_id'].toString().isNotEmpty;
  }

  Future<void> _processPayment() async {
    if (_pin.length != _maxPinLength || _isProcessing || _userId == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // First verify PIN if it's an existing PIN
      if (_hasExistingPin) {
        final verifyResult = await _verifyPin(_userId!, _pin);
        
        if (verifyResult['success'] != true) {
          setState(() {
            _isProcessing = false;
            _pin = '';
          });
          
          String errorMessage = verifyResult['error'] ?? 'PIN tidak valid';
          if (verifyResult['attempts_remaining'] != null) {
            errorMessage += '\nSisa percobaan: ${verifyResult['attempts_remaining']}';
          }
          
          _showErrorDialog('PIN Salah', errorMessage);
          return;
        }
      }

      // PIN verified or newly created, proceed with payment
      final refId = _isPascabayarTransaction() 
          ? widget.product['ref_id'].toString() 
          : _generateRefId();
      
      String apiEndpoint;
      Map<String, dynamic> requestBody;
      
      if (_isPascabayarTransaction()) {
        apiEndpoint = 'https://api.ditokoku.id/api/pay-transaction';
        requestBody = {
          "customer_no": widget.phoneNumber,
          "buyer_sku_code": widget.product['buyer_sku_code'],
          "ref_id": refId,
          "user_id": _userId, // 👈 Added user_id here
          "testing": true
        };
      } else {
        apiEndpoint = 'https://api.ditokoku.id/api/order-transaction';
        requestBody = {
          "customer_no": widget.phoneNumber,
          "buyer_sku_code": widget.product['buyer_sku_code'],
          "ref_id": refId,
          "user_id": _userId, // 👈 Added user_id here
          "testing": false
        };
      }

      print('Payment Request Body: ${json.encode(requestBody)}'); // Debug log

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Memproses transaksi...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Payment Response: ${response.statusCode}');
      print('Payment Response Body: ${response.body}'); // Debug log

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionReceiptPage(
                  product: widget.product,
                  phoneNumber: widget.phoneNumber,
                  provider: widget.provider,
                  transactionData: responseData,
                ),
              ),
            );
          }
        } else {
          _showErrorDialog(
            'Transaksi Gagal',
            responseData['message'] ?? 'Transaksi tidak dapat diproses',
          );
        }
      } else {
        _showErrorDialog(
          'Kesalahan Jaringan',
          'Gagal terhubung ke server. Silakan coba lagi.',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if still open
      }
      _showErrorDialog('Kesalahan', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message, VoidCallback onOk) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onProcessPayment() {
    if (_pin.length == _maxPinLength && !_isProcessing) {
      _processPayment();
    }
  }

  void _resetCreatePin() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirmPinMode = false;
    });
  }

  String _getPageTitle() {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return 'Buat PIN Baru';
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return 'Konfirmasi PIN';
    } else {
      return 'Verifikasi PIN';
    }
  }

  String _getPinInputTitle() {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return 'Buat PIN 6 Digit';
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return 'Ulangi PIN Anda';
    } else {
      return 'Masukan PIN';
    }
  }

  String _getButtonText() {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return 'LANJUTKAN';
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return 'BUAT PIN';
    } else {
      return _isPascabayarTransaction() ? 'BAYAR TAGIHAN' : 'PROSES PEMBAYARAN';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: Text(
          _getPageTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_isCreatePinMode && _isConfirmPinMode)
            TextButton(
              onPressed: _isProcessing ? null : _resetCreatePin,
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Info message for PIN creation
            if (_isCreatePinMode && !_isConfirmPinMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anda belum memiliki PIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan buat PIN 6 digit untuk keamanan transaksi Anda',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            // PIN Input Title
            Text(
              _getPinInputTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // PIN Input Boxes
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxPinLength, (index) {
                  String currentPin = _isCreatePinMode && _isConfirmPinMode ? _confirmPin : _pin;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index < currentPin.length ? Colors.blue[400]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        index < currentPin.length ? '•' : '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Number Pad
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    for (int i = 1; i <= 9; i++)
                      _buildNumberButton(i.toString()),
                    
                    Container(),
                    _buildNumberButton('0'),
                    
                    GestureDetector(
                      onTap: _isProcessing ? null : _onDeletePressed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isProcessing ? Colors.grey[200] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.backspace_outlined,
                          color: _isProcessing ? Colors.grey[400] : Colors.grey[600],
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _getButtonEnabled() ? _onProcessPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonEnabled()
                      ? const Color(0xFF396EB0) 
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'MEMPROSES...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _getButtonText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  bool _getButtonEnabled() {
    if (_isProcessing) return false;
    
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return _pin.length == _maxPinLength;
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return _confirmPin.length == _maxPinLength;
    } else {
      return _pin.length == _maxPinLength;
    }
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: _isProcessing ? Colors.grey[200] : Colors.grey[50],
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: _isProcessing ? Colors.grey[300]! : Colors.grey[200]!, 
            width: 1
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _isProcessing ? Colors.grey[400] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}