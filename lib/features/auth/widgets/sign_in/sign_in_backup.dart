import 'dart:convert';
import 'dart:math';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/controllers/otp_manager.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/otp_login_widget.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class SignInView extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  final Function(bool val)? isOtpViewEnable;
  
  const SignInView({
    super.key, 
    required this.exitFromApp, 
    required this.backFromThis, 
    this.fromResetPassword = false, 
    this.isOtpViewEnable
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  String _countryDialCode = '+62';
  GlobalKey<FormState>? _formKeyLogin;

  // Express.js API Configuration
  final String expressBaseUrl = 'https://api.ditokoku.id';

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    
    try {
      AuthController authController = Get.find<AuthController>();
      
      String savedCountryCode = authController.getUserCountryCode();
      if (savedCountryCode.isNotEmpty) {
        _countryDialCode = savedCountryCode;
      }
      
      _phoneController.text = authController.getUserNumber();
      authController.initCountryCode(countryCode: _countryDialCode);

      if (!kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_phoneFocus);
        });
      }
    } catch (e) {
      _countryDialCode = '+62';
      if (kDebugMode) {
        print('SignInView initState error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeyLogin,
      child: OtpLoginWidget(
        phoneController: _phoneController, 
        phoneFocus: _phoneFocus,
        countryDialCode: _countryDialCode,
        onCountryChanged: (CountryCode countryCode) {
          setState(() {
            _countryDialCode = countryCode.dialCode ?? '+62';
          });
        },
        onClickLoginButton: _sendWhatsAppOTP,
      ),
    );
  }

  String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  Future<void> _sendWhatsAppOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      showCustomSnackBar('Masukkan nomor WhatsApp Anda');
      return;
    }

    if (!_formKeyLogin!.currentState!.validate()) {
      return;
    }

    String phone = _phoneController.text.trim();
    String numberWithCountryCode = _countryDialCode + phone;
    
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    if (!phoneValid.isValid) {
      showCustomSnackBar('Nomor WhatsApp tidak valid');
      return;
    }

    try {
      String otp = generateOTP();
      
      // Step 1: Store OTP ke Laravel database terlebih dahulu
      print('Storing OTP to Laravel database: $otp');
      bool otpStored = await _storeOTPToLaravel(otp, numberWithCountryCode);
      
      if (!otpStored) {
        showCustomSnackBar('Gagal menyimpan OTP. Silakan coba lagi.');
        return;
      }
      
      // Step 2: Store OTP lokal juga (backup)
      await Get.find<OtpManager>().storeOTP(otp, numberWithCountryCode);
      
      // Step 3: Kirim OTP via WhatsApp
      String whatsappNumber = numberWithCountryCode.replaceAll('+', '');
      if (whatsappNumber.startsWith('620')) {
        whatsappNumber = '62${whatsappNumber.substring(3)}';
      }

      final response = await http.post(
        Uri.parse('http://84.247.151.106:4004/api/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': whatsappNumber,
          'message': 'Kode OTP Ditokoku: $otp. Jaga kerahasiaan kode. Tim
Ditokoku tidak pernah meminta OTP melalui kanal apa pun.
Jika tidak merasa meminta OTP, segera abaikan pesan ini.
Segala risiko, kerugian, dan/atau penyalahgunaan yang
timbul karena membagikan kode, kelalaian menjaga OTP,
atau penggunaan oleh pihak ketiga berada di luar tanggung
jawab Ditokoku'
        }),
      );

      if (response.statusCode == 200) {
        AuthController authController = Get.find<AuthController>();
        if (authController.isActiveRememberMe) {
          authController.saveUserNumberAndPassword(phone, '', _countryDialCode);
        } else {
          authController.clearUserNumberAndPassword();
        }

        showCustomSnackBar('OTP telah dikirim ke WhatsApp Anda', isError: false);

        // Navigate ke custom verification screen
        await Future.delayed(Duration(milliseconds: 300));
        Get.toNamed(RouteHelper.getCustomVerificationRoute(numberWithCountryCode));
      } else {
        showCustomSnackBar('Gagal mengirim OTP. Silakan coba lagi.');
      }
    } catch (e) {
      showCustomSnackBar('Terjadi kesalahan. Periksa koneksi internet Anda.');
      if (kDebugMode) {
        print('Error sending WhatsApp OTP: $e');
      }
    }
  }

  // Method baru untuk store OTP ke Laravel database
  Future<bool> _storeOTPToLaravel(String otp, String phoneNumber) async {
    try {
      print('Calling Express.js API to store OTP: $expressBaseUrl/api/store-otp');
      
      final response = await http.post(
        Uri.parse('$expressBaseUrl/api/users/store-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'phone': phoneNumber,
          'otp': otp,
        }),
      ).timeout(Duration(seconds: 10));

      print('Store OTP Response Status: ${response.statusCode}');
      print('Store OTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true || responseData['success'] == true) {
          print('OTP stored successfully to Laravel database');
          return true;
        }
      }
      
      print('Failed to store OTP to Laravel database');
      return false;
      
    } catch (e) {
      print('Error storing OTP to Laravel: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
}