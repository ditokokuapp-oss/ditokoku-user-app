import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';


class TopUpSuccessPage extends StatelessWidget {
  final String paymentMethod;
  final int amount;

  const TopUpSuccessPage({
    super.key,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Success Message
              Text(
                'Top Up Berhasil!',
                style: robotoBold.copyWith(
                  fontSize: 24,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Saldo Anda telah berhasil ditambahkan',
                style: robotoRegular.copyWith(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Transaction Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Metode Pembayaran', paymentMethod),
                    const SizedBox(height: 16),
                    _buildDetailRow('Nominal', PriceConverter.convertPrice(amount.toDouble())),
                    const SizedBox(height: 16),
                    _buildDetailRow('Status', 'Berhasil', valueColor: Colors.green[600]),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Back to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/dashboard', // Replace with your dashboard route
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Dashboard',
                    style: robotoBold.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: 14,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}