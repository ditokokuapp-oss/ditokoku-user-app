import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/taxi_guest_track_order_input_view_widget.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/trip_order_view_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    if(AuthHelper.isLoggedIn()) {
      Get.find<TaxiOrderController>().getTripList(1, isRunning: true);
      Get.find<TaxiOrderController>().getTripList(1, isRunning: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'trip'.tr, backButton: false),
      body: isLoggedIn ? Column(children: [

        TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
          unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          tabs: [
            Tab(text: 'running'.tr),
            Tab(text: 'history'.tr),
          ],
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: const [
            TripOrderViewWidget(isRunning: true),
            TripOrderViewWidget(isRunning: false),
          ],
        )),

      ]) : const TaxiGuestTrackOrderInputViewWidget(),
    );
  }
}
