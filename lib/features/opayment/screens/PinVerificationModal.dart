import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'TransactionReceiptPage.dart';

class PinVerificationModal extends StatefulWidget {
  final Map<String, dynamic> product;
  final String phoneNumber;
  final String provider;
  final String? providerLogo;

  const PinVerificationModal({
    super.key,
    required this.product,
    required this.phoneNumber,
    required this.provider,
    this.providerLogo, 
  });

  @override
  State<PinVerificationModal> createState() => _PinVerificationModalState();
}

class _PinVerificationModalState extends State<PinVerificationModal> {
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
  String? _userPhone;
  
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      final profileController = Get.find<ProfileController>();
      
      if (profileController.userInfoModel?.id != null) {
        _userId = profileController.userInfoModel!.id.toString();
        _userPhone = profileController.userInfoModel!.phone;
        print('User ID: $_userId');
        print('User Phone: $_userPhone');
        
        final pinStatus = await _detectPin(_userId!);
        
        setState(() {
          _hasExistingPin = pinStatus['has_pin'] == true;
          _isCreatePinMode = !_hasExistingPin;
          _isLoading = false;
        });
        
        print('Has existing PIN: $_hasExistingPin');
      } else {
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

  Future<Map<String, dynamic>> _detectPin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/pin/detect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

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

  Future<String> _sendOTP(String phoneNumber) async {
    try {
      // Generate OTP 6 digit
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();
      
      final response = await http.post(
        Uri.parse('http://84.247.151.106:4004/api/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phoneNumber,
          'message': 'Kode OTP Ditokoku: $otp. Jaga kerahasiaan kode. Tim Ditokoku tidak pernah meminta OTP melalui kanal apa pun. Jika tidak merasa meminta OTP, segera abaikan pesan ini. Segala risiko, kerugian, dan/atau penyalahgunaan yang timbul karena membagikan kode, kelalaian menjaga OTP, atau penggunaan oleh pihak ketiga berada di luar tanggung jawab Ditokoku'
        }),
      );

      if (response.statusCode == 200) {
        return otp;
      } else {
        throw Exception('Gagal mengirim OTP');
      }
    } catch (e) {
      print('Send OTP Error: $e');
      throw Exception('Gagal mengirim OTP: $e');
    }
  }

  Future<Map<String, dynamic>> _updatePin(String userId, String newPin) async {
    try {
      final response = await http.put(
        Uri.parse('https://api.ditokoku.id/api/pin/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'new_pin': newPin,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to update PIN'
        };
      }
    } catch (e) {
      print('PIN Update Error: $e');
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }

  void _showForgotPinFlow() async {
    if (_userPhone == null || _userPhone!.isEmpty) {
      _showErrorDialog('Error', 'Nomor telepon tidak ditemukan');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Kirim OTP
      final generatedOtp = await _sendOTP(_userPhone!);
      
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      // Tampilkan dialog OTP
      _showOTPDialog(generatedOtp);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Error', 'Gagal mengirim OTP: $e');
    }
  }

  void _showOTPDialog(String correctOtp) {
    String enteredOtp = '';
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Masukkan Kode OTP',
                style: TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kode OTP telah dikirim ke $_userPhone',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan 6 digit OTP',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      enteredOtp = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: isVerifying ? null : () async {
                    if (enteredOtp.length != 6) {
                      _showErrorDialog('Error', 'Masukkan 6 digit OTP');
                      return;
                    }

                    if (enteredOtp == correctOtp) {
                      Navigator.of(dialogContext).pop();
                      // OTP benar, tampilkan form set PIN baru
                      _showSetNewPinDialog();
                    } else {
                      _showErrorDialog('Error', 'Kode OTP salah');
                    }
                  },
                  child: isVerifying 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Verifikasi',
                        style: TextStyle(color: Colors.black),
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetNewPinDialog() {
    String newPin = '';
    String confirmNewPin = '';
    bool isConfirmMode = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2F318B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                isConfirmMode ? 'Ulangi PIN Baru' : 'Buat PIN Baru',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isConfirmMode 
                      ? 'Masukkan kembali PIN baru Anda' 
                      : 'Masukkan PIN baru 6 digit',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      String currentPin = isConfirmMode ? confirmNewPin : newPin;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: index < currentPin.length ? Colors.white : Colors.white30,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Number pad
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) return const SizedBox();
                      if (index == 11) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (isConfirmMode && confirmNewPin.isNotEmpty) {
                                confirmNewPin = confirmNewPin.substring(0, confirmNewPin.length - 1);
                              } else if (!isConfirmMode && newPin.isNotEmpty) {
                                newPin = newPin.substring(0, newPin.length - 1);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.backspace_outlined, color: Colors.white),
                          ),
                        );
                      }
                      
                      String number = index == 10 ? '0' : (index + 1).toString();
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (isConfirmMode) {
                              if (confirmNewPin.length < 6) {
                                confirmNewPin += number;
                                if (confirmNewPin.length == 6) {
                                  // Check if pins match
                                  Future.delayed(const Duration(milliseconds: 300), () async {
                                    if (newPin == confirmNewPin) {
                                      // Save new PIN
                                      final result = await _updatePin(_userId!, newPin);
                                      Navigator.of(dialogContext).pop();
                                      
                                      if (result['success'] == true) {
                                        _showSuccessDialog(
                                          'PIN Berhasil Diubah',
                                          'PIN Anda telah berhasil diubah',
                                          () {},
                                        );
                                      } else {
                                        _showErrorDialog('Error', result['error'] ?? 'Gagal mengubah PIN');
                                      }
                                    } else {
                                      _showErrorDialog('PIN Tidak Cocok', 'PIN yang Anda masukkan tidak sama');
                                      setDialogState(() {
                                        newPin = '';
                                        confirmNewPin = '';
                                        isConfirmMode = false;
                                      });
                                    }
                                  });
                                }
                              }
                            } else {
                              if (newPin.length < 6) {
                                newPin += number;
                                if (newPin.length == 6) {
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    setDialogState(() {
                                      isConfirmMode = true;
                                    });
                                  });
                                }
                              }
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onNumberPressed(String number) {
    if (_isProcessing) return;

    if (_isCreatePinMode && !_isConfirmPinMode) {
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
      if (_pin.length < _maxPinLength) {
        setState(() {
          _pin += number;
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_isProcessing) return;

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
    if ((_hasExistingPin && _pin.length != _maxPinLength) || _isProcessing || _userId == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
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
          "user_id": _userId,
          "testing": true
        };
      } else {
        apiEndpoint = 'https://api.ditokoku.id/api/order-transaction';
        requestBody = {
          "customer_no": widget.phoneNumber,
          "buyer_sku_code": widget.product['buyer_sku_code'],
          "ref_id": refId,
          "user_id": _userId,
          "testing": false
        };
      }

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionReceiptPage(
                  product: widget.product,
                  phoneNumber: widget.phoneNumber,
                  provider: widget.provider,
                  transactionData: responseData,
                  providerLogo: widget.providerLogo,
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
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
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
          backgroundColor: const Color(0xFF2F318B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onProcessPayment() {
    if (_getButtonEnabled()) {
      if (_isCreatePinMode && _isConfirmPinMode) {
        _checkPinMatch();
      } else if (_hasExistingPin && _pin.length == _maxPinLength) {
        _processPayment();
      }
    }
  }

  String _getPinInputTitle() {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return 'Buat PIN 6 Digit';
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return 'Ulangi PIN Anda';
    } else {
      return 'Masukkan PIN';
    }
  }

  String _getButtonText() {
    if (_isCreatePinMode && !_isConfirmPinMode) {
      return 'LANJUTKAN';
    } else if (_isCreatePinMode && _isConfirmPinMode) {
      return 'BUAT PIN';
    } else {
      return 'Proses Pembayaran';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      _getPinInputTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: _isProcessing ? null : () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: _isProcessing ? Colors.grey : Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_maxPinLength, (index) {
                  String currentPin = _isCreatePinMode && _isConfirmPinMode ? _confirmPin : _pin;
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: index < currentPin.length ? Colors.black : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 30),
            
            if (!_isCreatePinMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: _isProcessing ? null : _showForgotPinFlow,
                  child: const Text(
                    'Lupa PIN?',
                    style: TextStyle(
                      color: Color(0xFF2F318B),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int row = 0; row < 3; row++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int col = 1; col <= 3; col++)
                            _buildNumberButton((row * 3 + col).toString()),
                        ],
                      ),
                    ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmptyButton(),
                      _buildNumberButton('0'),
                      _buildDeleteButton(),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _getButtonEnabled() ? _onProcessPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonEnabled()
                        ? const Color(0xFF2F318B) 
                        : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'MEMPROSES...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _getButtonText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _isProcessing ? Colors.grey[400] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _onDeletePressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: _isProcessing ? Colors.grey[400] : Colors.black,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyButton() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.transparent,
    );
  }
}