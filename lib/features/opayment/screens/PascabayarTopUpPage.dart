import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'PaymentDetailPage.dart';

class PascabayarTopUpPage extends StatefulWidget {
  final String serviceName;
  final String serviceDescription;
  final String logoPath;
  final String buyerSkuCode;
  final Color? serviceColor;
  final String serviceType; // 'pln', 'internet', 'pdam', 'bpjs'

  const PascabayarTopUpPage({
    super.key,
    required this.serviceName,
    required this.serviceDescription,
    required this.logoPath,
    required this.buyerSkuCode,
    this.serviceColor,
    required this.serviceType,
  });

  @override
  State<PascabayarTopUpPage> createState() => _PascabayarTopUpPageState();
}

class _PascabayarTopUpPageState extends State<PascabayarTopUpPage> {
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
    return widget.serviceColor ?? _getDefaultColor();
  }

  Color _getDefaultColor() {
    switch (widget.serviceType) {
      case 'pln':
        return Colors.blue[700]!;
      case 'internet':
        return Colors.red[700]!;
      case 'pdam':
        return Colors.blue[600]!;
      case 'bpjs': // ✅ Tambah support BPJS
        return Colors.green[700]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData get serviceIcon {
    switch (widget.serviceType) {
      case 'pln':
        return Icons.flash_on;
      case 'internet':
        return Icons.wifi;
      case 'pdam':
        return Icons.water_drop;
      case 'bpjs': // ✅ Tambah icon untuk BPJS
        return Icons.local_hospital;
      default:
        return Icons.receipt_long;
    }
  }

  String get inputHint {
    switch (widget.serviceType) {
      case 'pln':
        return 'Masukan ID Pelanggan PLN';
      case 'internet':
        return 'Masukan Nomor Pelanggan';
      case 'pdam':
        return 'Masukan Nomor Pelanggan PDAM';
      case 'bpjs': // ✅ Tambah hint untuk BPJS
        return 'Masukan Nomor BPJS';
      default:
        return 'Masukan Nomor Pelanggan';
    }
  }

  String get inputLabel {
    switch (widget.serviceType) {
      case 'pln':
        return 'ID Pelanggan';
      case 'internet':
      case 'pdam':
        return 'Nomor Pelanggan';
      case 'bpjs': // ✅ Tambah label untuk BPJS
        return 'Nomor BPJS';
      default:
        return 'Nomor Pelanggan';
    }
  }

  Future<void> _checkBill() async {
    if (_customerNoController.text.isEmpty) {
      setState(() {
        errorMessage = 'Masukkan ${inputLabel.toLowerCase()} terlebih dahulu';
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
          'testing': false,
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
        automaticallyImplyLeading: false, // jangan munculin back bawaan
        titleSpacing: 0, // hilangin padding default AppBar
        title: Row(
          children: [
            // Tambahin padding biar ga mepet kiri
            Padding(
              padding: const EdgeInsets.only(left: 12), // ⬅️ kasih jarak kiri
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/image/goback.png',
                  width: 31,
                  height: 31,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 13), // jarak icon ke teks
            Text(
              widget.serviceName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
                    child: Center(
                      child: Image.asset(
                        widget.logoPath,
                        width: 101,
                        height: 101,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 101,
                            height: 101,
                            decoration: BoxDecoration(
                              color: serviceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              serviceIcon,
                              size: 60,
                              color: serviceColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Input section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Masukan ${inputLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
                            color: Colors.white, // ✅ background putih
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x662F318B), // ✅ #2F318B dengan 40% opacity
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Text input
                              Expanded(
                                child: TextFormField(
                                  controller: _customerNoController,
                                  keyboardType: widget.serviceType == 'bpjs' 
                                    ? TextInputType.text  // BPJS bisa ada huruf
                                    : TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: inputHint,
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFBAB0B0), // hint abu
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Service logo on the right side of input
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
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
                                        serviceIcon,
                                        size: 16,
                                        color: serviceColor,
                                      ),
                                    );
                                  },
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
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x662F318B),
                              width: 1.5,
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
                              : Image.asset(
                                  'assets/image/search.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.search,
                                      color: serviceColor,
                                      size: 24,
                                    );
                                  },
                                ),
                          ),
                        ),
                      ),
                    ],
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
                        Text(
                          'Informasi Tagihan ${_getServiceTypeTitle()}',
                          style: const TextStyle(
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
                    _buildInfoRow(inputLabel, billInfo!['customer_no'] ?? '-'),
                    
                    // Service specific info
                    ..._buildServiceSpecificInfo(),
                    
                    // Detail tagihan per periode
                    if (billInfo!['desc'] != null && 
                        billInfo!['desc']['detail'] != null && 
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
                              _buildInfoRow('Biaya Admin', _formatPrice(detail['admin'])),
                              if (detail['denda'] != null && detail['denda'] != '0')
                                _buildInfoRow('Denda', _formatPrice(detail['denda'])),
                              if (detail['materai'] != null && detail['materai'] != '0')
                                _buildInfoRow('Materai', _formatPrice(detail['materai'])),
                            ],
                          ),
                        ),
                      )),
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
                          // Create product object for PaymentDetailPage
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
                                providerLogo: widget.logoPath, // ✅ Menambahkan providerLogo seperti PulsaDataPage
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
                        child: Text(
                          widget.serviceType == 'bpjs' ? 'BAYAR BPJS' : 'BAYAR TAGIHAN',
                          style: const TextStyle(
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

  String _getServiceTypeTitle() {
    switch (widget.serviceType) {
      case 'pln':
        return 'PLN';
      case 'internet':
        return 'Internet & TV';
      case 'pdam':
        return 'PDAM';
      case 'bpjs': // ✅ Tambah title untuk BPJS
        return 'BPJS';
      default:
        return '';
    }
  }

  List<Widget> _buildServiceSpecificInfo() {
    List<Widget> widgets = [];
    
    if (billInfo!['desc'] != null) {
      final desc = billInfo!['desc'];
      
      widgets.add(const SizedBox(height: 12));
      widgets.add(const Divider());
      widgets.add(const SizedBox(height: 12));
      
      switch (widget.serviceType) {
        case 'pln':
          if (desc['tarif'] != null) {
            widgets.add(_buildInfoRow('Tarif', desc['tarif']));
          }
          if (desc['daya'] != null) {
            widgets.add(_buildInfoRow('Daya', '${desc['daya']} VA'));
          }
          break;
          
        case 'pdam':
          if (desc['golongan'] != null) {
            widgets.add(_buildInfoRow('Golongan', desc['golongan']));
          }
          if (desc['meter_awal'] != null && desc['meter_akhir'] != null) {
            final pemakaian = (int.tryParse(desc['meter_akhir'].toString()) ?? 0) - 
                             (int.tryParse(desc['meter_awal'].toString()) ?? 0);
            widgets.add(_buildInfoRow('Pemakaian', '${desc['meter_akhir']} - ${desc['meter_awal']} = $pemakaian m³'));
          }
          break;
          
        case 'bpjs': // ✅ Tambah info khusus BPJS jika ada
          if (desc['kelas'] != null) {
            widgets.add(_buildInfoRow('Kelas', desc['kelas']));
          }
          if (desc['faskes'] != null) {
            widgets.add(_buildInfoRow('Faskes', desc['faskes']));
          }
          break;
          
        case 'internet':
          // Add specific info for internet if needed
          break;
      }
      
      if (desc['lembar_tagihan'] != null) {
        widgets.add(_buildInfoRow('Lembar Tagihan', '${desc['lembar_tagihan']}'));
      }
    }
    
    return widgets;
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