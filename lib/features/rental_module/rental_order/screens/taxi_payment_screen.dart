import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/cancel_payment_dialog_widget.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TaxiPaymentScreen extends StatefulWidget {
  final String? paymentUrl;
  final int orderId;
  const TaxiPaymentScreen({super.key, required this.paymentUrl, required this.orderId});

  @override
  TaxiPaymentScreenState createState() => TaxiPaymentScreenState();
}

class TaxiPaymentScreenState extends State<TaxiPaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();

    selectedUrl = widget.paymentUrl??'';
    if (kDebugMode) {
      print('==========url=======> $selectedUrl');
    }

    _initData();
  }

  void _initData() async {

    browser = MyInAppBrowser(orderID: widget.orderId, guestId: '2334');

    if(GetPlatform.isAndroid){
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController = ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // print('=====mmmmm.> $didPop // $result');
        // _exitApp().then((value) {
        //   print('=====ooooo> $value');
        //   return value!;
        // });
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    return Get.dialog(const CancelPaymentDialogWidget());
  }

}

class MyInAppBrowser extends InAppBrowser {
  final int orderID;
  final double? orderAmount;
  final String? url;
  final String guestId;

  MyInAppBrowser({
    super.windowId, super.initialUserScripts,
    required this.orderID, required this.guestId, this.orderAmount, this.url});

  late bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _redirect(url.toString());

  }


  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _redirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

 void _redirect(String url) {
   if (_canRedirect) {
     bool isSuccess = url.startsWith('${AppConstants.baseUrl}/?flag=success');
     bool isFailed = url.startsWith('${AppConstants.baseUrl}/?flag=fail');
     bool isCancel = url.startsWith('${AppConstants.baseUrl}/?flag=cancel');
     if (isSuccess || isFailed || isCancel) {
       _canRedirect = false;
       close();
       Future.delayed(const Duration(milliseconds: 400), () {
         Get.back(result: true);
         Get.find<TaxiOrderController>().getTripDetails(orderID);
       });
       // Get.offAllNamed(RouteHelper.getInitialRoute());
     }

   }
 }
}