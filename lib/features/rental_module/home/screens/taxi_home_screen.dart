import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/home/widgets/banner_widget.dart';
import 'package:sixam_mart/features/rental_module/widgets/coupons_widget.dart';
import 'package:sixam_mart/features/rental_module/home/widgets/my_address_widget.dart';
import 'package:sixam_mart/features/rental_module/widgets/refer_and_earn_new.dart';
import 'package:sixam_mart/features/rental_module/widgets/searchbar_widget.dart';
import 'package:sixam_mart/features/rental_module/home/widgets/top_rated_vehicle_widget.dart';
import 'package:sixam_mart/features/rental_module/widgets/trip_history_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class TaxiHomeScreen extends StatefulWidget {
  const TaxiHomeScreen({super.key});

  @override
  State<TaxiHomeScreen> createState() => _TaxiHomeScreenState();
}

class _TaxiHomeScreenState extends State<TaxiHomeScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<TaxiHomeController>().getTaxiBannerList(false);
    Get.find<TaxiHomeController>().getTopRatedCarList(1, false);
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
      Get.find<TaxiOrderController>().getTripList(1, isRunning: false, fromHome: true);
      Get.find<TaxiHomeController>().getTaxiCouponList(false);
      // Get.find<TaxiHomeController>().getHistoryTripList(1, false);
      Get.find<TaxiFavouriteController>().getFavouriteTaxiList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Container(color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Banner Image
            const BannerWidget(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            const SearchbarWidget(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if(isLoggedIn)
              const MyAddressWidget(),

            if(isLoggedIn)
              const TripHistoryWidget(),

            const TopRatedVehicleWidget(),

            if(isLoggedIn)
              const CouponWidget(),

            const ReferAndEarnCard(),
            const SizedBox(height: 60)

          ]),
        ),
      ),
    );
  }
}




