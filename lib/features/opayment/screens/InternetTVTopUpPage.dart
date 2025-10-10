import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'PaymentDetailPage.dart';

class InternetTVTopUpPage extends StatefulWidget {
  final String serviceName;
  final String serviceDescription;
  final String logoPath;
  final String buyerSkuCode;

  const InternetTVTopUpPage({
    super.key,
    required this.serviceName,
    required this.serviceDescription,
    required this.logoPath,
    required this.buyerSkuCode,
  });

  @override
  State<InternetTVTopUpPage> createState() => _InternetTVTopUpPageState();
}

class _InternetTVTopUpPageState extends State<InternetTVTopUpPage> {
  final TextEditingController _customerNoController = TextEditingController();
  bool isCheckingBill = false;
  Map<String, dynamic>? billInfo;
  String? errorMessage;

  @override
  void dispose() {
    _customerNoController.dispose();
    super.dispose();
  }

  Color get serviceColor {
    return Colors.red[700]!;
  }

  Future<void> _checkBill() async {
    if (_customerNoController.text.isEmpty) {
      setState(() {
        errorMessage = 'Masukkan nomor pelanggan terlebih dahulu';
      });
      return;
    }

    setState(() {
      isCheckingBill = true;
      billInfo = null;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/inquiry-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_no': _customerNoController.text,
          'buyer_sku_code': widget.buyerSkuCode,
          'testing': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          setState(() {
            billInfo = data['digiflazz_response']['data'];
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Gagal mengambil data tagihan';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal terhubung ke server. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error checking bill: $e');
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isCheckingBill = false;
      });
    }
  }

  String _formatPrice(dynamic price) {
    double priceDouble = 0;
    if (price is String) {
      priceDouble = double.tryParse(price) ?? 0;
    } else if (price is int) {
      priceDouble = price.toDouble();
    } else if (price is double) {
      priceDouble = price;
    }
    
    return 'Rp${priceDouble.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.serviceName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo and input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Service logo
                  Container(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            widget.logoPath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.wifi,
                                size: 60,
                                color: serviceColor,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: serviceColor, width: 2),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: serviceColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Input section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Nomor Pelanggan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Customer number input
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: serviceColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Service logo in input field
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Image.asset(
                                  widget.logoPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: serviceColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.wifi,
                                        size: 16,
                                        color: serviceColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // Text input
                              Expanded(
                                child: TextFormField(
                                  controller: _customerNoController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Masukan Nomor Pelanggan',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Check button
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: isCheckingBill ? null : _checkBill,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: serviceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: serviceColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: isCheckingBill
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(serviceColor),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: serviceColor,
                                  size: 24,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Service name display
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: serviceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: serviceColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi,
                          size: 16,
                          color: serviceColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.serviceName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: serviceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Error message
            if (errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Bill info display
            if (billInfo != null) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Informasi Tagihan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Customer info
                    _buildInfoRow('Nama Pelanggan', billInfo!['customer_name'] ?? '-'),
                    _buildInfoRow('Nomor Pelanggan', billInfo!['customer_no'] ?? '-'),
                    
                    // Bill details
                    if (billInfo!['desc'] != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Tarif and Daya info
                      if (billInfo!['desc']['tarif'] != null)
                        _buildInfoRow('Tarif', billInfo!['desc']['tarif']),
                      if (billInfo!['desc']['daya'] != null)
                        _buildInfoRow('Daya', '${billInfo!['desc']['daya']} VA'),
                      if (billInfo!['desc']['lembar_tagihan'] != null)
                        _buildInfoRow('Lembar Tagihan', '${billInfo!['desc']['lembar_tagihan']}'),
                      
                      // Detail tagihan per periode
                      if (billInfo!['desc']['detail'] != null && 
                          (billInfo!['desc']['detail'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Detail Tagihan:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        ...((billInfo!['desc']['detail'] as List).map((detail) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Periode', detail['periode'] ?? '-'),
                                _buildInfoRow('Nilai Tagihan', _formatPrice(detail['nilai_tagihan'])),
                                _buildInfoRow('Admin', _formatPrice(detail['admin'])),
                                if (detail['denda'] != null && detail['denda'] != '0')
                                  _buildInfoRow('Denda', _formatPrice(detail['denda'])),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ],
                    
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Tagihan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _formatPrice(billInfo!['selling_price']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: serviceColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Pay button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Create product object similar to the one expected by PaymentDetailPage
                          final productForPayment = {
                            'product_name': '${widget.serviceName} - ${billInfo!['customer_name']}',
                            'price': billInfo!['selling_price'].toString(),
                            'admin': billInfo!['admin'].toString(),
                            'buyer_sku_code': billInfo!['buyer_sku_code'],
                            'ref_id': billInfo!['ref_id'],
                          };
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentDetailPage(
                                product: productForPayment,
                                phoneNumber: _customerNoController.text,
                                provider: widget.serviceName,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: serviceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'BAYAR TAGIHAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}