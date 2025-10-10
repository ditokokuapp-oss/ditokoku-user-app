import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopUpHistoryPage extends StatefulWidget {
  const TopUpHistoryPage({super.key});

  @override
  State<TopUpHistoryPage> createState() => _TopUpHistoryPageState();
}

class _TopUpHistoryPageState extends State<TopUpHistoryPage> {
  List<TripayTopUpModel> topUpTransactions = [];
  bool isLoadingTransactions = true;
  String? transactionError;
  
  // Ganti dengan URL backend Anda
  static const String BACKEND_URL = 'https://api.ditokoku.id';

  @override
  void initState() {
    super.initState();
    _loadTopUpHistory();
  }

  Future<void> _loadTopUpHistory() async {
    try {
      setState(() {
        isLoadingTransactions = true;
        transactionError = null;
      });

      // Get email from ProfileController
      String? userEmail;
      try {
        final profileController = Get.find<ProfileController>();
        userEmail = profileController.userInfoModel?.email;
      } catch (e) {
        setState(() {
          transactionError = 'Gagal mendapatkan data user';
          isLoadingTransactions = false;
        });
        return;
      }

      if (userEmail == null || userEmail.isEmpty) {
        setState(() {
          transactionError = 'Email user tidak ditemukan';
          isLoadingTransactions = false;
        });
        return;
      }

      // Call API
      final response = await http.get(
        Uri.parse('$BACKEND_URL/api/tripay/topup/email/$userEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          topUpTransactions = data.map((json) => TripayTopUpModel.fromJson(json)).toList();
          
          // Sort by created_at descending (newest first)
          topUpTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          isLoadingTransactions = false;
        });

        // Auto check status untuk transaksi UNPAID (WAIT sampai selesai)
        await _autoCheckUnpaidTransactions();
      } else {
        setState(() {
          transactionError = 'Gagal memuat data: ${response.statusCode}';
          isLoadingTransactions = false;
        });
      }
    } catch (e) {
      setState(() {
        transactionError = 'Terjadi kesalahan: $e';
        isLoadingTransactions = false;
      });
    }
  }

  // Auto check status untuk transaksi yang masih UNPAID (hanya 1x saat load pertama)
  Future<void> _autoCheckUnpaidTransactions() async {
    final unpaidTransactions = topUpTransactions
        .where((t) => t.status.toUpperCase() == 'UNPAID')
        .toList();

    if (unpaidTransactions.isEmpty) return;

    print('======== AUTO CHECKING UNPAID TRANSACTIONS ========');
    print('Found ${unpaidTransactions.length} unpaid transactions');

    bool hasStatusChanged = false;

    for (var transaction in unpaidTransactions) {
      try {
        final statusChanged = await _checkAndUpdateTransactionStatus(transaction.reference);
        if (statusChanged) hasStatusChanged = true;
        // Delay sedikit antar request
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Error checking status for ${transaction.reference}: $e');
      }
    }

    // Reload history HANYA jika ada perubahan status
    if (hasStatusChanged) {
      print('Status changed detected, reloading history...');
      await _loadTopUpHistory();
    }
  }

  // Check status dan UPDATE ke database jika ada perubahan
  Future<bool> _checkAndUpdateTransactionStatus(String reference) async {
    try {
      print('Checking status for: $reference');
      
      // 1. Cek status dari Tripay
      final statusResponse = await http.get(
        Uri.parse('$BACKEND_URL/api/tripay/status/$reference'),
        headers: {'Content-Type': 'application/json'},
      );

      if (statusResponse.statusCode == 200) {
        final statusData = json.decode(statusResponse.body);
        final newStatus = statusData['data']?['status'] ?? '';
        
        print('Current status from Tripay for $reference: $newStatus');

        // 2. Jika status bukan UNPAID, update ke database
        if (newStatus != 'UNPAID') {
          print('Status changed to $newStatus, updating database...');
          
          // Update status di database via API
          final updateResponse = await http.put(
            Uri.parse('$BACKEND_URL/api/tripay/topup/update-status'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'reference': reference,
              'status': newStatus,
            }),
          );

          print('Update API Response Code: ${updateResponse.statusCode}');
          print('Update API Response Body: ${updateResponse.body}');

          if (updateResponse.statusCode == 200) {
            final updateData = json.decode(updateResponse.body);
            if (updateData['success'] == true) {
              print('✅ Status updated successfully in database');
              return true; // Ada perubahan
            } else {
              print('❌ Update failed: ${updateData['message']}');
              return false;
            }
          } else {
            print('❌ Failed to update status in database: ${updateResponse.statusCode}');
            return false;
          }
        }
      }
      
      return false; // Tidak ada perubahan
    } catch (e) {
      print('Error checking/updating status: $e');
      return false;
    }
  }

  // Manual check untuk satu transaksi (dipanggil dari UI)
  Future<void> _manualCheckStatus(TripayTopUpModel transaction) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengecek status pembayaran...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final statusChanged = await _checkAndUpdateTransactionStatus(transaction.reference);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (statusChanged) {
        // Reload history jika ada perubahan
        await _loadTopUpHistory();
        
        // Show success message
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Colors.green,
          message: 'Status berhasil diperbarui',
          duration: const Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        ));
      } else {
        // Tidak ada perubahan
        Get.showSnackbar(GetSnackBar(
          backgroundColor: Colors.blue,
          message: 'Status masih sama, belum ada perubahan',
          duration: const Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        ));
      }
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.red,
        message: 'Gagal mengecek status',
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/image/goback.png',
              width: 31,
              height: 31,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          'Riwayat Top Up',
          style: robotoBold.copyWith(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadTopUpHistory,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTopUpHistory,
        child: _buildTransactionList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (isLoadingTransactions) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => _buildTransactionShimmer(),
      );
    }

    if (transactionError != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                transactionError!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTopUpHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (topUpTransactions.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada riwayat top up',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topUpTransactions.length,
      itemBuilder: (context, index) {
        return _buildTopUpItem(topUpTransactions[index]);
      },
    );
  }

  Widget _buildTransactionShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Shimmer(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  child: Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Shimmer(
            child: Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpItem(TripayTopUpModel transaction) {
    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'PAID':
          return Colors.green;
        case 'UNPAID':
          return Colors.orange;
        case 'FAILED':
        case 'EXPIRED':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getStatusText(String status) {
      switch (status.toUpperCase()) {
        case 'PAID':
          return 'BERHASIL';
        case 'UNPAID':
          return 'BELUM BAYAR';
        case 'FAILED':
          return 'GAGAL';
        case 'EXPIRED':
          return 'KADALUARSA';
        default:
          return status.toUpperCase();
      }
    }

    String formatDate(DateTime date) {
      // Convert UTC to WIB (UTC+7)
      final wibDate = date.toUtc().add(const Duration(hours: 9));
      final now = DateTime.now();
      final difference = now.difference(wibDate);
      
      if (difference.inDays == 0) {
        return 'Hari ini, ${wibDate.hour.toString().padLeft(2, '0')}:${wibDate.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Kemarin, ${wibDate.hour.toString().padLeft(2, '0')}:${wibDate.minute.toString().padLeft(2, '0')}';
      } else {
        return '${wibDate.day}/${wibDate.month}/${wibDate.year}, ${wibDate.hour.toString().padLeft(2, '0')}:${wibDate.minute.toString().padLeft(2, '0')}';
      }
    }

    final isUnpaid = transaction.status.toUpperCase() == 'UNPAID';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTransactionDetail(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: getStatusColor(transaction.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: getStatusColor(transaction.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Transaction details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Up Saldo',
                            style: robotoBold.copyWith(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.paymentMethod,
                            style: robotoRegular.copyWith(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(transaction.createdAt),
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: getStatusColor(transaction.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              getStatusText(transaction.status),
                              style: robotoBold.copyWith(
                                fontSize: 10,
                                color: getStatusColor(transaction.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          PriceConverter.convertPrice(double.parse(transaction.amount)),
                          style: robotoBold.copyWith(
                            fontSize: 15,
                            color: getStatusColor(transaction.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.reference.length > 12 
                              ? transaction.reference.substring(0, 12) + '...'
                              : transaction.reference,
                          style: robotoRegular.copyWith(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Tombol cek status untuk transaksi UNPAID
                if (isUnpaid) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _manualCheckStatus(transaction),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Cek Status Pembayaran'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(TripayTopUpModel transaction) {
    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'PAID':
          return Colors.green;
        case 'UNPAID':
          return Colors.orange;
        case 'FAILED':
        case 'EXPIRED':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getStatusText(String status) {
      switch (status.toUpperCase()) {
        case 'PAID':
          return 'BERHASIL';
        case 'UNPAID':
          return 'BELUM BAYAR';
        case 'FAILED':
          return 'GAGAL';
        case 'EXPIRED':
          return 'KADALUARSA';
        default:
          return status.toUpperCase();
      }
    }

    final isUnpaid = transaction.status.toUpperCase() == 'UNPAID';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Transaksi',
                    style: robotoBold.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Status
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: getStatusColor(transaction.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        transaction.status.toUpperCase() == 'PAID'
                            ? Icons.check_circle
                            : transaction.status.toUpperCase() == 'UNPAID'
                                ? Icons.access_time
                                : Icons.cancel,
                        color: getStatusColor(transaction.status),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      getStatusText(transaction.status),
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: getStatusColor(transaction.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Transaction Details
              _buildDetailRow('Jumlah', PriceConverter.convertPrice(double.parse(transaction.amount))),
              _buildDetailRow('Metode Pembayaran', transaction.paymentMethod),
              _buildDetailRow('Referensi Tripay', transaction.reference),
              _buildDetailRow('Merchant Ref', transaction.merchantRef),
              _buildDetailRow('Nama Customer', transaction.customerName),
              _buildDetailRow('Email', transaction.customerEmail),
              _buildDetailRow('Nomor HP', transaction.customerPhone),
              _buildDetailRow(
                'Tanggal', 
                '${transaction.createdAt.toUtc().add(const Duration(hours: 7)).day}/${transaction.createdAt.toUtc().add(const Duration(hours: 7)).month}/${transaction.createdAt.toUtc().add(const Duration(hours: 7)).year} ${transaction.createdAt.toUtc().add(const Duration(hours: 7)).hour.toString().padLeft(2, '0')}:${transaction.createdAt.toUtc().add(const Duration(hours: 7)).minute.toString().padLeft(2, '0')} WIB'
              ),
              
              const SizedBox(height: 24),
              
              // Tombol cek status untuk transaksi UNPAID
              if (isUnpaid) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _manualCheckStatus(transaction);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cek Status Pembayaran'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF396EB0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tutup',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: robotoBold.copyWith(
                fontSize: 14,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Model untuk Tripay Top Up Transaction
class TripayTopUpModel {
  final int id;
  final String reference;
  final String merchantRef;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String amount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  TripayTopUpModel({
    required this.id,
    required this.reference,
    required this.merchantRef,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory TripayTopUpModel.fromJson(Map<String, dynamic> json) {
    return TripayTopUpModel(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? '',
      merchantRef: json['merchant_ref'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}