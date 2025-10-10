import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: SafeArea(
        child: GetBuilder<OnBoardingController>(
          builder: (onBoardingController) {
            return onBoardingController.onBoardingList.isNotEmpty 
              ? SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth, 
                      child: PageView.builder(
                        itemCount: 3, // Fix: hardcode ke 3 slide saja
                        controller: _pageController,
                        itemBuilder: (context, index) {
                          // List gambar onboarding
                          List<String> onboardImages = [
                            'assets/image/onboard1.png',
                            'assets/image/onboard2.png',
                            'assets/image/onboard3.png',
                          ];
                          
                          return Stack(
                            children: [
                              // Full background image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(onboardImages[index]),
                                    fit: BoxFit.cover,
                                    alignment: Alignment(0, -0.05)
                                  ),
                                ),
                              ),
                              
                              // Bottom content (button + skip text)
                              Positioned(
                                bottom: index == 0 ? 30 : 0,
                                left: 20,
                                right: 20,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tombol Lanjut / Mulai
                                    SizedBox(
                                      width: 327,
                                      child: CustomButton(
                                        buttonText: index == 2 ? 'Mulai' : 'Lanjut',
                                        onPressed: () {
                                          if (index != 2) {
                                            _pageController.nextPage(
                                              duration: const Duration(milliseconds: 300), 
                                              curve: Curves.ease
                                            );
                                          } else {
                                            // Slide terakhir: arahkan ke sign in
                                            _navigateToSignIn();
                                          }
                                        },
                                        radius: 16,
                                        height: 52,
                                        fontSize: 18,
                                      ),
                                    ),
                                    
                                    // Tulisan "Lewati" - arahkan ke sign in
                                    if (index > 0) ...[
                                      const SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () {
                                          _navigateToSignIn();
                                        },
                                        child: Text(
                                          'Lewati',
                                          style: robotoMedium.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF5DCBAD),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        onPageChanged: (index) {
                          onBoardingController.changeSelectIndex(index);
                        },
                      ),
                    ),
                  ),
                )
              : const SizedBox();
          },
        ),
      ),
    );
  }

  // Navigasi ke halaman Sign In
  void _navigateToSignIn() {
    Get.find<SplashController>().disableIntro();
    Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.onBoarding));
  }

  // Navigasi untuk mode guest (lewati login)
  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true);
    }
  }
}