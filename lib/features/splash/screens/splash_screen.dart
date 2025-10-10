import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;

    _onConnectivityChanged =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected =
          result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: Duration(seconds: isConnected ? 3 : 6),
            content: Text(
              isConnected ? 'connected'.tr : 'no_connection'.tr,
              textAlign: TextAlign.center,
            ),
          ),
        );

        // ✅ NAVIGATION ENABLED: Navigasi saat reconnect diaktifkan kembali
        if (isConnected) {
          Get.find<SplashController>().getConfigData(notificationBody: widget.body);
        }
      }

      firstTime = false;
    });

    // ✅ NAVIGATION ENABLED: Aktifkan kembali init shared data
    Get.find<SplashController>().initSharedData();

    if ((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) &&
        Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();
    }

    // ✅ NAVIGATION ENABLED: Aktifkan kembali navigasi dengan delay 3 detik
    Timer(Duration(seconds: 3), () {
      Get.find<SplashController>().getConfigData(notificationBody: widget.body);
    });
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NAVIGATION ENABLED: Aktifkan kembali init shared data
    Get.find<SplashController>().initSharedData();

    // ✅ NAVIGATION ENABLED: Aktifkan kembali address check
    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: 
      // ✅ NAVIGATION ENABLED: Menggunakan GetBuilder untuk trigger navigation
      GetBuilder<SplashController>(builder: (splashController) {
        return splashController.hasConnection
            ? 
            Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/bgnewbackground.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    // Logo di tengah layar dengan posisi lebih ke atas
                    Expanded(
                      flex: 1, // Kurangi space di atas biar logo lebih ke atas
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 4, // Tambah space untuk konten utama
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/image/newlogoditokoku.png',
                              width: 151,
                              height: 151,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                            // ✅ Loading indicator untuk menunjukkan app sedang loading
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 10),
                           
                          ],
                        ),
                      ),
                    ),

                    // Layout bagian bawah
                   Expanded(
  flex: 1,
  child: Padding(
    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10), // kiri-kanan sama
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center, // 🔑 biar center semua
      children: const [
        Text(
          'Ditokoku menghubungkan belanja, kuliner, transportasi,',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.2, // 🔑 bikin rapet
          ),
        ),
        SizedBox(height: 2), // 🔑 kasih jarak antar baris
        Text(
          'pengiriman, PPOB, dan jasa dalam satu aplikasi.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Transaksi aman, cepat, nyaman.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.2,
          ),
        ),
      ],
    ),
  ),
),

                  ],
                ),
              )
            : NoInternetScreen(child: SplashScreen(body: widget.body));
      }),
    );
  }
}