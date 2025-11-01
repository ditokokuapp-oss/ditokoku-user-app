import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TopUpService.dart';

class AgentTopUpWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  final String paymentMethod;
  final int amount;
  final String? reference;
  final Map<String, dynamic> agentData; // Data agen

  const AgentTopUpWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.paymentMethod,
    required this.amount,
    this.reference,
    required this.agentData,
  });

  @override
  State<AgentTopUpWebViewPage> createState() => _AgentTopUpWebViewPageState();
}

class _AgentTopUpWebViewPageState extends State<AgentTopUpWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _pageTitle = '';
  bool _isProcessingPayment = false;
  String? _extractedReference;

  static const String BACKEND_URL = 'https://api.ditokoku.id';

  @override
  void initState() {
    super.initState();
    _extractedReference = widget.reference;
    _initializeWebView();
  }

  String? _extractReferenceFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      if (uri.queryParameters.containsKey('tripay_reference')) {
        final ref = uri.queryParameters['tripay_reference'];
        print('✅ Found tripay_reference: $ref');
        return ref;
      }
      
      if (uri.queryParameters.containsKey('reference')) {
        final ref = uri.queryParameters['reference'];
        print('✅ Found reference: $ref');
        return ref;
      }
      
      if (uri.queryParameters.containsKey('tripay_merchant_ref')) {
        final ref = uri.queryParameters['tripay_merchant_ref'];
        print('✅ Found tripay_merchant_ref: $ref');
        return ref;
      }
      
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final lastSegment = segments.last;
        if (lastSegment.startsWith('T') && lastSegment.length > 5) {
          print('✅ Found reference from path: $lastSegment');
          return lastSegment;
        }
      }
      
      final tripayMatch = RegExp(r'[?&]tripay_reference=([^&]+)').firstMatch(url);
      if (tripayMatch != null) {
        final ref = tripayMatch.group(1);
        print('✅ Found tripay_reference via regex: $ref');
        return ref;
      }
      
      final match = RegExp(r'[?&]reference=([^&]+)').firstMatch(url);
      if (match != null) {
        final ref = match.group(1);
        print('✅ Found reference via regex: $ref');
        return ref;
      }
      
      print('❌ No reference found in URL: $url');
      
    } catch (e) {
      print('❌ Error extracting reference from URL: $e');
    }
    return null;
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _controller.getTitle().then((title) {
              setState(() {
                _pageTitle = title ?? '';
              });
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation to: ${request.url}');
            
            if (_extractedReference == null) {
              _extractedReference = _extractReferenceFromUrl(request.url);
              if (_extractedReference != null) {
                print('✅ Reference extracted from URL: $_extractedReference');
              }
            }
            
            if (_isSuccessUrl(request.url)) {
              if (!_isProcessingPayment) {
                _checkPaymentStatus();
              }
              return NavigationDecision.prevent;
            }
            
            if (_isFailureUrl(request.url)) {
              _handlePaymentFailed();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isSuccessUrl(String url) {
    return url.contains('success') || 
           url.contains('completed') ||
           url.contains('/tripay/success') ||
           url.contains('status=success');
  }

  bool _isFailureUrl(String url) {
    return url.contains('failed') || 
           url.contains('cancelled') ||
           url.contains('/tripay/failed') ||
           url.contains('status=failed');
  }

  Future<void> _checkPaymentStatus() async {
    if (_isProcessingPayment) return;
    
    if (_extractedReference == null || _extractedReference!.isEmpty) {
      print('❌ ERROR: Reference not found');
      _showErrorSnackbar();
      return;
    }
    
    setState(() {
      _isProcessingPayment = true;
    });

    print('======== CHECKING PAYMENT STATUS FOR AGENT ========');
    print('Reference: $_extractedReference');
    print('Agent Data: ${widget.agentData}');
    print('Timestamp: ${DateTime.now().toIso8601String()}');

    try {
      _showProcessingDialog();

      final response = await http.get(
        Uri.parse('$BACKEND_URL/api/tripay/status/$_extractedReference'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status API Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['data']?['status'] ?? '';
        
        print('Payment Status: $status');

        if (status == 'PAID') {
          print('✅ Status is PAID - Processing agent registration');
          await _handleAgentPaymentSuccess();
        } else {
          print('⚠️ Status is not PAID (Status: $status)');
          Navigator.of(context).pop();
          _showPendingPaymentSnackbar();
          setState(() {
            _isProcessingPayment = false;
          });
        }
      } else {
        throw Exception('Failed to check status: ${response.statusCode}');
      }

    } catch (e) {
      print('ERROR: Status check failed: $e');
      Navigator.of(context).pop();
      _showErrorSnackbar();
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<void> _handleAgentPaymentSuccess() async {
    print('======== PROCESSING AGENT REGISTRATION ========');

    try {
      // 1. Add funds ke wallet
      print('--- Step 1: Adding funds to wallet ---');
      await _tryAddFundsWithTopUpService();

      // 2. Register agen
      print('--- Step 2: Registering agent ---');
      await _registerAgent();

      // 3. Refresh profile
      print('--- Step 3: Refreshing profile ---');
      await _refreshUserProfile();

      Navigator.of(context).pop(); // Close loading dialog
      _showAgentSuccessMessage();
      _navigateToHome();

      print('======== AGENT REGISTRATION COMPLETED ========');

    } catch (e) {
      print('ERROR: Agent registration failed: $e');
      
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _showAgentErrorMessage(e.toString());
      _navigateToHome();
    }
  }

  Future<void> _tryAddFundsWithTopUpService() async {
    try {
      print('=== Adding funds via TopUpService ===');
      
      final result = await TopUpService.addFundsToWallet(
        amount: widget.amount.toDouble(),
        reference: _extractedReference ?? 'AGENT_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      print('TopUpService result: ${result.success} - ${result.message}');
      
      if (!result.success) {
        throw Exception('TopUpService failed: ${result.message}');
      }
      
    } catch (e) {
      print('CRITICAL ERROR: TopUpService failed: $e');
      throw e;
    }
  }

  Future<void> _registerAgent() async {
    try {
      print('=== Registering agent ===');
      
      
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userInfoModel?.id;
      
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.post(
        Uri.parse('$BACKEND_URL/api/users/agen'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'nama_konter': widget.agentData['nama_konter'],
          'alamat': widget.agentData['alamat'],
          'kode_referal': widget.agentData['kode_referal'] ?? '',
        }),
      );

      print('Agent API Response Code: ${response.statusCode}');
      print('Agent API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print('✅ Agent registered successfully with ID: ${data['id']}');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to register agent');
        }
      } else {
        throw Exception('Failed to register agent: ${response.statusCode}');
      }
      
    } catch (e) {
      print('CRITICAL ERROR: Agent registration failed: $e');
      throw e;
    }
  }

  Future<void> _refreshUserProfile() async {
    try {
      print('Refreshing user profile...');
      final profileController = Get.find<ProfileController>();
      await profileController.getUserInfo();
      
      if (mounted) {
        setState(() {});
      }
      
      print('Profile refreshed successfully');
    } catch (e) {
      print('ERROR: Failed to refresh profile: $e');
    }
  }

  void _handlePaymentFailed() {
    _showFailureMessage();
    _navigateToHome();
  }

  void _showProcessingDialog() {
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
                  Text('Memproses pendaftaran agen...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAgentSuccessMessage() {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.green,
      message: '🎉 Selamat! Anda berhasil terdaftar sebagai agen',
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  void _showAgentErrorMessage(String error) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.orange,
      message: 'Pembayaran berhasil, namun ada kendala: $error',
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  void _showPendingPaymentSnackbar() {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.orange,
      message: 'Pembayaran belum diterima, silahkan refresh',
      duration: const Duration(seconds: 4),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          _checkPaymentStatus();
        },
        child: const Text('REFRESH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ));
  }

  void _showErrorSnackbar() {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.red,
      message: 'Gagal mengecek status pembayaran',
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  void _showFailureMessage() {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.red,
      message: 'Pembayaran gagal atau dibatalkan',
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    ));
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _showExitDialog(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle.isNotEmpty ? _pageTitle : 'Pembayaran Pendaftaran Agen',
              style: robotoBold.copyWith(fontSize: 16, color: Colors.black),
            ),
            Text(
              '${widget.paymentMethod} • ${PriceConverter.convertPrice(widget.amount.toDouble())}',
              style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat halaman pembayaran...', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batalkan Pendaftaran?', style: robotoBold.copyWith(fontSize: 18, color: Colors.black)),
        content: Text('Apakah Anda yakin ingin membatalkan pendaftaran agen?', style: robotoRegular.copyWith(fontSize: 14, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak', style: robotoRegular.copyWith(fontSize: 14, color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Ya, Batalkan', style: robotoBold.copyWith(fontSize: 14, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}