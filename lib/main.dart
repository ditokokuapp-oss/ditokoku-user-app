import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/notification_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/auth/controllers/otp_manager.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/cookies_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();

  /*///Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };


  ///Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };*/

  if(GetPlatform.isWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyDhzr85jPExzZs3cpyF9R-xA_h0f783zmA",
        authDomain: "ditokokuid-a2ff4.firebaseapp.com",
        projectId: "ditokokuid-a2ff4",
        storageBucket: "ditokokuid-a2ff4.firebasestorage.app",
        messagingSenderId: "268802509862",
        appId: "1:268802509862:web:8e688673b4b3ff61adaae7"
    ));
  } else if(GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAAaZMiI4Tb_kNFFIhtq4msd0a9fij3iaM",
        appId: "1:268802509862:android:45686a8bc946acdeadaae7",
        messagingSenderId: "268802509862",
        projectId: "ditokokuid-a2ff4",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() async {
    if(GetPlatform.isWeb) {
       Get.find<SplashController>().initSharedData();
      if(AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if(!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/) {
        await Get.find<AuthController>().guestLogin();
      }

      if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }

      Get.find<SplashController>().getConfigData(loadLandingData: (GetPlatform.isWeb && AddressHelper.getUserAddressFromSharedPref() == null), fromMainFunction: true);
    }
  }

  @override
  Widget build(BuildContext context) {

    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.dark,
    //   statusBarBrightness: Brightness.dark,
    //   systemNavigationBarColor: Colors.transparent,
    //   systemNavigationBarIconBrightness: Brightness.dark,
    // ));

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: _buildTheme(themeController.darkTheme ? dark() : light()),
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (BuildContext context, widget) {
              return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), child: Material(
                child: SafeArea(
                  top: false, bottom: GetPlatform.isAndroid,
                  child: Stack(children: [
                    widget!,

                    GetBuilder<SplashController>(builder: (splashController){
                      if(!splashController.savedCookiesData && !splashController.getAcceptCookiesStatus(splashController.configModel != null ? splashController.configModel!.cookiesText! : '')){
                        return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter, child: CookiesView()) : const SizedBox();
                      }else{
                        return const SizedBox();
                      }
                    })
                  ]),
                ),
              ));
          },
          );
        });
      });
    });
  }

  // Method untuk menerapkan font Poppins ke theme secara general
  ThemeData _buildTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      // Set font family untuk semua text theme
      textTheme: baseTheme.textTheme.apply(
        fontFamily: 'Poppins',
      ),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(
        fontFamily: 'Poppins',
      ),
      // Set font family untuk komponen UI lainnya
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Poppins',
        ),
      ),
      // Set font family untuk button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontFamily: 'Poppins'),
          ),
        ) ?? ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: baseTheme.textButtonTheme.style?.copyWith(
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontFamily: 'Poppins'),
          ),
        ) ?? TextButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: baseTheme.outlinedButtonTheme.style?.copyWith(
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontFamily: 'Poppins'),
          ),
        ) ?? OutlinedButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      // Set font family untuk input decoration
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        labelStyle: baseTheme.inputDecorationTheme.labelStyle?.copyWith(
          fontFamily: 'Poppins',
        ) ?? const TextStyle(fontFamily: 'Poppins'),
        hintStyle: baseTheme.inputDecorationTheme.hintStyle?.copyWith(
          fontFamily: 'Poppins',
        ) ?? const TextStyle(fontFamily: 'Poppins'),
      ),
      // Set font family untuk dialog
      dialogTheme: baseTheme.dialogTheme.copyWith(
        titleTextStyle: baseTheme.dialogTheme.titleTextStyle?.copyWith(
          fontFamily: 'Poppins',
        ) ?? const TextStyle(fontFamily: 'Poppins'),
        contentTextStyle: baseTheme.dialogTheme.contentTextStyle?.copyWith(
          fontFamily: 'Poppins',
        ) ?? const TextStyle(fontFamily: 'Poppins'),
      ),
      // Set font family untuk snackbar
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        contentTextStyle: baseTheme.snackBarTheme.contentTextStyle?.copyWith(
          fontFamily: 'Poppins',
        ) ?? const TextStyle(fontFamily: 'Poppins'),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}