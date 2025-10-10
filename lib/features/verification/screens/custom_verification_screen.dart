import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/controllers/otp_manager.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CustomVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const CustomVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<CustomVerificationScreen> createState() => _CustomVerificationScreenState();
}

class _CustomVerificationScreenState extends State<CustomVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final OtpManager _otpManager = Get.find<OtpManager>();
  bool _isLoading = false;
  String currentText = "";
  
  // Debug variables
  int _verifyAttempts = 0;
  List<String> _debugLogs = [];

  // Express.js API Configuration  
  final String expressBaseUrl = 'https://api.ditokoku.id';

  void _addDebugLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    setState(() {
      _debugLogs.add(logMessage);
    });
    print(logMessage);
  }

  @override
  void initState() {
    super.initState();
    _addDebugLog('CustomVerificationScreen initialized for ${widget.phoneNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? null : AppBar(
        title: Text('Verifikasi OTP'),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masukkan Kode OTP',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  
                  Text(
                    'Kode OTP telah dikirim ke WhatsApp\n${widget.phoneNumber}\nVerify Attempts: $_verifyAttempts',
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                    length: 6,
                    textStyle: robotoBold.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                    obscureText: false,
                    obscuringCharacter: '*',
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      borderWidth: 1,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).disabledColor,
                      selectedColor: Theme.of(context).primaryColor,
                      activeFillColor: Theme.of(context).cardColor,
                      inactiveFillColor: Theme.of(context).cardColor,
                      selectedFillColor: Theme.of(context).cardColor,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      currentText = v;
                      _addDebugLog('OTP completed: ${v.length} digits');
                    },
                    onChanged: (value) {
                      currentText = value;
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButton(
                    buttonText: _isLoading ? 'Memverifikasi...' : 'Verifikasi',
                    isLoading: _isLoading,
                    onPressed: _verifyOTP,
                    radius: Dimensions.radiusDefault,
                    height: 50,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InkWell(
                    onTap: _resendOTP,
                    child: Text(
                      'Kirim Ulang OTP',
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (currentText.length != 6) {
      showCustomSnackBar('Masukkan kode OTP 6 digit');
      return;
    }

    _addDebugLog('Starting OTP verification');
    
    setState(() {
      _isLoading = true;
    });

    try {
      _verifyAttempts++;
      setState(() {}); // Update UI

      // Method 1: Verify with Express.js API first
      _addDebugLog('Attempting Express.js API verification');
      bool expressVerified = await _verifyWithExpressAPI();
      
      if (expressVerified) {
        _addDebugLog('Express.js verification successful - proceeding with AuthController login');
        await _handleSuccessfulVerification();
        return;
      }

      // Method 2: Fallback to local verification if Express.js fails
      _addDebugLog('Express.js verification failed, trying local verification as fallback');
      bool localVerified = await _otpManager.verifyOTP(currentText, widget.phoneNumber);
      
      if (localVerified) {
        _addDebugLog('Local verification successful');
        await _handleSuccessfulVerification();
      } else {
        _addDebugLog('Both Express.js and local verification failed');
        showCustomSnackBar('Kode OTP tidak valid atau sudah kedaluwarsa');
      }

    } catch (e) {
      _addDebugLog('Error in _verifyOTP: $e');
      showCustomSnackBar('Terjadi kesalahan saat verifikasi');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _verifyWithExpressAPI() async {
    try {
      _addDebugLog('Calling Express.js API: $expressBaseUrl/api/users/verify-phone');
      
      final response = await http.post(
        Uri.parse('$expressBaseUrl/api/users/verify-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'otp': currentText,
          'verification_type': 'phone',
          'phone': widget.phoneNumber,
          'login_type': 'otp',
        }),
      ).timeout(Duration(seconds: 15));

      _addDebugLog('Express.js API Response Status: ${response.statusCode}');
      _addDebugLog('Express.js API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Check if response indicates success
        if (responseData.containsKey('token') || 
            responseData.containsKey('is_phone_verified') ||
            responseData.containsKey('message')) {
          
          _addDebugLog('Express.js API verification successful');
          return true;
        }
        
        return false;
        
      } else if (response.statusCode == 404) {
        _addDebugLog('Express.js API returned 404 - OTP not found or invalid');
        return false;
        
      } else if (response.statusCode == 403) {
        final responseData = json.decode(response.body);
        if (responseData['errors'] != null && responseData['errors'].isNotEmpty) {
          String errorMessage = responseData['errors'][0]['message'] ?? 'Validation error';
          _addDebugLog('Express.js API validation error: $errorMessage');
        }
        return false;
        
      } else {
        _addDebugLog('Express.js API returned status ${response.statusCode}');
        return false;
      }
      
    } on SocketException {
      _addDebugLog('Network error: No internet connection');
      return false;
    } on FormatException {
      _addDebugLog('Network error: Invalid response format');
      return false;
    } on http.ClientException {
      _addDebugLog('Network error: Client exception');
      return false;
    } catch (e) {
      _addDebugLog('Error in _verifyWithExpressAPI: $e');
      return false;
    }
  }

  Future<void> _handleSuccessfulVerification() async {
    try {
      _addDebugLog('Verification successful, processing...');
      
      // Clear OTP after successful verification
      await _otpManager.clearOTP();
      _addDebugLog('OTP cleared from local storage');

      // Directly call Express.js login API instead of AuthController
      try {
        _addDebugLog('Calling Express.js login API directly...');
        
        final response = await http.post(
          Uri.parse('$expressBaseUrl/api/users/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'login_type': 'otp',
            'phone': widget.phoneNumber,
            'otp': currentText,
            'verified': 'yes',
          }),
        ).timeout(Duration(seconds: 15));

        _addDebugLog('Express.js login API Response Status: ${response.statusCode}');
        _addDebugLog('Express.js login API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          _addDebugLog('Express.js login successful');
          
          // Save token and auth state manually
          if (responseData['token'] != null && 
              responseData['token'].toString().isNotEmpty &&
              responseData['token'] != 'null') {
            
            String token = responseData['token'].toString();
            _addDebugLog('Saving auth token: ${token.substring(0, 20)}...');
            
            // Save token using AuthController method
            AuthController authController = Get.find<AuthController>();
            authController.saveUserNumberAndPassword(widget.phoneNumber, token, '+62');
            authController.update();
            
            _addDebugLog('Token saved and AuthController updated');
          }
          
          // Check if personal info is complete
          int isPersonalInfo = responseData['is_personal_info'] ?? 0;
          _addDebugLog('Personal info complete: $isPersonalInfo');
          
          if (isPersonalInfo == 1) {
            // Personal info complete - full login
            _addDebugLog('Personal info complete, proceeding to full login');
            
            // Load user profile and cart
            try {
              _addDebugLog('Loading user profile data...');
              await Get.find<ProfileController>().getUserInfo();
              _addDebugLog('User profile loaded successfully');
              
              _addDebugLog('Loading cart data...');
              await Get.find<CartController>().getCartDataOnline();
              _addDebugLog('Cart data loaded successfully');
              
            } catch (e) {
              _addDebugLog('Warning: Could not load user/cart data: $e');
              // Continue anyway
            }
            
            showCustomSnackBar('Login berhasil', isError: false);
            _addDebugLog('Navigating to dashboard');
            
            // Navigate to home/dashboard
            Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
            
          } else {
            // Personal info incomplete - redirect to registration
            _addDebugLog('Personal info incomplete, redirecting to registration');
            showCustomSnackBar('Silakan lengkapi data registrasi', isError: false);
            
            Get.offNamed(RouteHelper.getSignUpRoute(), arguments: {
              'phone': widget.phoneNumber,
              'verified': true,
            });
          }
          
        } else if (response.statusCode == 404) {
          _addDebugLog('Express.js login failed - OTP not found');
          showCustomSnackBar('Kode OTP tidak valid atau sudah kedaluwarsa');
          
        } else {
          final responseData = json.decode(response.body);
          String errorMessage = 'Gagal login';
          
          if (responseData['errors'] != null && responseData['errors'].isNotEmpty) {
            errorMessage = responseData['errors'][0]['message'] ?? errorMessage;
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
          
          _addDebugLog('Express.js login failed: $errorMessage');
          showCustomSnackBar(errorMessage);
        }
        
      } catch (apiError) {
        _addDebugLog('Express.js login API error: $apiError');
        showCustomSnackBar('Terjadi kesalahan saat login');
      }
      
    } catch (e) {
      _addDebugLog('Error in _handleSuccessfulVerification: $e');
      showCustomSnackBar('Terjadi kesalahan saat memproses verifikasi');
    }
  }

  Future<void> _resendOTP() async {
    _addDebugLog('User requested OTP resend');
    Get.back();
    showCustomSnackBar('Silakan minta OTP baru dari halaman login', isError: false);
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Information'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${widget.phoneNumber}'),
              Text('Verify Attempts: $_verifyAttempts'),
              Text('Current OTP: $currentText'),
              Text('Express.js Endpoint: /api/verify-phone'),
              Text('Express Base URL: $expressBaseUrl'),
              SizedBox(height: 10),
              Text('Debug Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: _debugLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _debugLogs[index],
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              final logs = _debugLogs.join('\n');
              print('=== DEBUG LOGS ===');
              print(logs);
              print('=== END LOGS ===');
              Navigator.pop(context);
              showCustomSnackBar('Logs printed to console', isError: false);
            },
            child: Text('Print Logs'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}