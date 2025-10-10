import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TopUpAmountPage.dart';

class DaftarAgenPage extends StatefulWidget {
  const DaftarAgenPage({super.key});

  @override
  State<DaftarAgenPage> createState() => _DaftarAgenPageState();
}

class _DaftarAgenPageState extends State<DaftarAgenPage> {
  final TextEditingController _namaKonterController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  bool _isAgreed = false;
  List<dynamic> _snkData = [];
  bool _isLoadingSnk = false;
  String _minTopup = '50000';
  bool _isLoadingConfig = true;

  @override
  void initState() {
    super.initState();
    _fetchConfigPrice();
  }

  @override
  void dispose() {
    _namaKonterController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _fetchConfigPrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/config-price'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          setState(() {
            _minTopup = double.parse(jsonData['data']['min_topup']).toStringAsFixed(0);
            _isLoadingConfig = false;
          });
        } else {
          throw Exception('Failed to load config price');
        }
      } else {
        throw Exception('Failed to load config price');
      }
    } catch (e) {
      setState(() {
        _isLoadingConfig = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat konfigurasi harga: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _fetchSnkData() async {
    setState(() {
      _isLoadingSnk = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/snk-agen'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            _snkData = jsonData['data'];
            _isLoadingSnk = false;
          });
        } else {
          throw Exception('Failed to load SNK data');
        }
      } else {
        throw Exception('Failed to load SNK data');
      }
    } catch (e) {
      setState(() {
        _isLoadingSnk = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat data SNK: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showTermsModal() async {
    // Fetch SNK data before showing modal
    await _fetchSnkData();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Syarat & Ketentuan\nAgen PPOB Opayment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.3,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: _isLoadingSnk
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _snkData.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data SNK',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Build sections from API data
                              ..._snkData.map((section) {
                                return _buildSection(
                                  title: '${section['order']}. ${section['title']}',
                                  items: List<String>.from(section['items']),
                                );
                              }).toList(),

                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Informasi Penting',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue[900],
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Dengan mendaftar sebagai Agen PPOB Opayment, Anda dianggap telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan yang berlaku.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[900],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F318B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Saya Mengerti dan Setuju',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_namaKonterController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama konter harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_alamatController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Alamat harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!_isAgreed) {
      Get.snackbar(
        'Error',
        'Silakan centang persetujuan isi saldo minimal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.to(
      () => TopUpAmountPage(
        paymentMethod: '',
        paymentCode: '',
        logoPath: '',
        isFromAgentRegistration: true,
        minTopupAmount: int.parse(_minTopup),
        agentData: {
          'nama_konter': _namaKonterController.text,
          'alamat': _alamatController.text,
        },
      ),
    );
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Daftar Agen',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Nama Konter Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _namaKonterController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nama Konter',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.store_outlined,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Alamat Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _alamatController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Alamat',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Agreement Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _isAgreed,
                            onChanged: (value) {
                              setState(() {
                                _isAgreed = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingConfig
                              ? const Text(
                                  'Memuat konfigurasi...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Dengan Mendaftar agen, saya setuju untuk ',
                                      ),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsModal,
                                          child: Text(
                                            'Isi saldo Minimal Rp ${_formatCurrency(_minTopup)}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' agar bisa mulai berjualan PPOB',
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoadingConfig ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F318B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoadingConfig
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Daftar dan Isi Saldo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}