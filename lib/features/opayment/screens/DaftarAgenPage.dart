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
  final TextEditingController _kodeReferalController = TextEditingController();

  List<dynamic> _snkData = [];
  bool _isLoadingSnk = false;
  String _minTopup = '50000';
  bool _isLoadingConfig = true;

  bool _isCheckingReferal = false;
  String? _namaMarketing;

  @override
  void initState() {
    super.initState();
    _fetchConfigPrice();
  }

  @override
  void dispose() {
    _namaKonterController.dispose();
    _alamatController.dispose();
    _kodeReferalController.dispose();
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

  Future<void> _checkKodeReferal(String kode) async {
    if (kode.isEmpty) {
      setState(() {
        _namaMarketing = null;
      });
      return;
    }

    setState(() {
      _isCheckingReferal = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/users/marketing/check/$kode'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          setState(() {
            _namaMarketing = jsonData['data']['nama_marketing'];
          });
        } else {
          setState(() {
            _namaMarketing = 'not_found';
          });
        }
      } else {
        setState(() {
          _namaMarketing = 'not_found';
        });
      }
    } catch (e) {
      setState(() {
        _namaMarketing = 'not_found';
      });
    } finally {
      setState(() {
        _isCheckingReferal = false;
      });
    }
  }

  void _showFullScreenTermsModal() async {
    // Fetch SNK data terlebih dahulu
    await _fetchSnkData();
    if (!mounted) return;

    // Tampilkan fullscreen modal
    final bool? agreed = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullScreenTermsPage(
          snkData: _snkData,
          isLoadingSnk: _isLoadingSnk,
          minTopup: _minTopup,
        ),
      ),
    );

    // Jika user setuju, lanjut ke halaman top up
    if (agreed == true) {
      _proceedToTopUp();
    }
  }

  void _proceedToTopUp() {
    Get.to(() => TopUpAmountPage(
          paymentMethod: '',
          paymentCode: '',
          logoPath: '',
          isFromAgentRegistration: true,
          minTopupAmount: int.parse(_minTopup),
          agentData: {
            'nama_konter': _namaKonterController.text,
            'alamat': _alamatController.text,
            'kode_referal': _kodeReferalController.text,
            'nama_marketing': _namaMarketing,
          },
        ));
  }

  void _handleSubmit() {
    if (_namaKonterController.text.isEmpty) {
      Get.snackbar('Error', 'Nama konter harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    if (_alamatController.text.isEmpty) {
      Get.snackbar('Error', 'Alamat harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    // Tampilkan modal S&K fullscreen
    _showFullScreenTermsModal();
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount) ?? 0;
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
                    const Text('Daftar Agen Platinum',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 40),

                    // Nama Konter
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: TextField(
                        controller: _namaKonterController,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Nama Konter',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.store_outlined, color: Colors.grey[400], size: 28),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Alamat
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: TextField(
                        controller: _alamatController,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Alamat',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.location_on_outlined, color: Colors.grey[400], size: 28),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Kode Marketing (moved to bottom)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: TextField(
                        controller: _kodeReferalController,
                        onChanged: (val) {
                          if (val.length >= 3) _checkKodeReferal(val);
                        },
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Kode Marketing (opsional)',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.card_giftcard, color: Colors.grey[400], size: 28),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isCheckingReferal)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Row(children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text("Memeriksa kode marketing..."),
                        ]),
                      )
                    else if (_namaMarketing != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Text(
                          _namaMarketing == 'not_found'
                              ? "❌ Kode marketing tidak ditemukan"
                              : "✅ Ditemukan Marketing: $_namaMarketing",
                          style: TextStyle(
                            fontSize: 14,
                            color: _namaMarketing == 'not_found' ? Colors.red : Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoadingConfig
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Lanjutkan Pendaftaran',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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

// Fullscreen Terms & Conditions Page
class _FullScreenTermsPage extends StatefulWidget {
  final List<dynamic> snkData;
  final bool isLoadingSnk;
  final String minTopup;

  const _FullScreenTermsPage({
    required this.snkData,
    required this.isLoadingSnk,
    required this.minTopup,
  });

  @override
  State<_FullScreenTermsPage> createState() => _FullScreenTermsPageState();
}

class _FullScreenTermsPageState extends State<_FullScreenTermsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Check if user has scrolled to bottom (with 50px threshold)
      if (currentScroll >= maxScroll - 50 && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount) ?? 0;
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
                      decoration: BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'Syarat & Ketentuan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: widget.isLoadingSnk
                ? const Center(child: CircularProgressIndicator())
                : widget.snkData.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data SNK',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Syarat & Ketentuan\nAgen Platinum Opayment',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.3,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ...widget.snkData.map((section) {
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
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Dengan mendaftar sebagai Agen Platinum Opayment, Anda dianggap telah menyetujui seluruh syarat dan ketentuan yang berlaku serta bersedia isi saldo minimal Rp ${_formatCurrency(widget.minTopup)}.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[900],
                                        height: 1.4,
                                      ),
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
          // Bottom Button Section
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
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show indicator if not scrolled to bottom
                  if (!_hasScrolledToBottom)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.orange[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Scroll ke bawah untuk membaca semua ketentuan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _hasScrolledToBottom
                          ? () {
                              Navigator.pop(context, true); // Return true = setuju
                            }
                          : null, // Disabled if not scrolled to bottom
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasScrolledToBottom 
                            ? const Color(0xFF2F318B) 
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        'Setuju dan Lanjutkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _hasScrolledToBottom ? Colors.white : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false); // Return false = tidak setuju
                    },
                    child: const Text(
                      'Batalkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}