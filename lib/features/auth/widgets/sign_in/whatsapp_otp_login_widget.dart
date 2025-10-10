import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class WhatsAppOtpLoginWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final Function()? onClickLoginButton;

  const WhatsAppOtpLoginWidget({
    super.key,
    required this.phoneController,
    required this.phoneFocus,
    this.onClickLoginButton,
  });

  @override
  State<WhatsAppOtpLoginWidget> createState() => _WhatsAppOtpLoginWidgetState();
}

class _WhatsAppOtpLoginWidgetState extends State<WhatsAppOtpLoginWidget> {
  bool _isRememberMe = false;
  bool _isAgreeTerms = false;
  bool _isLoading = false;
  final String _countryDialCode = '+62';

  String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _sendWhatsAppOTP() async {
    if (widget.phoneController.text.trim().isEmpty) {
      showCustomSnackBar('Masukkan nomor WhatsApp Anda');
      return;
    }

    if (!_isAgreeTerms) {
      showCustomSnackBar('Harap setujui syarat & ketentuan terlebih dahulu');
      return;
    }

    String phone = widget.phoneController.text.trim();
    String fullNumber = _countryDialCode + phone;

    setState(() => _isLoading = true);

    try {
      String otp = generateOTP();

      // Format nomor WA (hapus +)
      String whatsappNumber = fullNumber.replaceAll('+', '');

      final response = await http.post(
        Uri.parse('http://84.247.151.106:4004/api/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': whatsappNumber, 'message': 'OTP anda $otp'}),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar('OTP telah dikirim ke WhatsApp Anda', isError: false);
      } else {
        showCustomSnackBar('Gagal mengirim OTP. Silakan coba lagi.');
      }
    } catch (e) {
      showCustomSnackBar('Terjadi kesalahan koneksi.');
      if (kDebugMode) print('Error sending WhatsApp OTP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Logo Dummy
        //   Container(
        //     height: 120,
        //     width: 120,
        //     decoration: BoxDecoration(
        //       color: Colors.blue,
        //       borderRadius: BorderRadius.circular(60),
        //     ),
        //     child: const Icon(Icons.whatsapp, size: 80, color: Colors.white),
        //   ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Ditokoku Tes WhatsApp OTP',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // Input nomor WA
          TextField(
            controller: widget.phoneController,
            focusNode: widget.phoneFocus,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixText: '+62 ',
              hintText: '812 3456 7890',
            ),
          ),
          const SizedBox(height: 20),

          // Remember me
          Row(
            children: [
              Checkbox(
                value: _isRememberMe,
                onChanged: (v) => setState(() => _isRememberMe = v ?? false),
              ),
              const Text("Ingat Saya"),
            ],
          ),

          // Terms
          Row(
            children: [
              Checkbox(
                value: _isAgreeTerms,
                onChanged: (v) => setState(() => _isAgreeTerms = v ?? false),
              ),
              const Flexible(
                child: Text("Saya setuju dengan Syarat & Ketentuan"),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              buttonText: 'Lanjut',
              onPressed: _isLoading ? null : _sendWhatsAppOTP,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
