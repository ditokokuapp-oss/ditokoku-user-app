import 'package:sixam_mart/features/rental_module/rental_favourite/controllers/taxi_favourite_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/widgets/favourite_vehicle_view_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleFavouriteScreen extends StatefulWidget {
  const VehicleFavouriteScreen({super.key});

  @override
  VehicleFavouriteScreenState createState() => VehicleFavouriteScreenState();
}

class VehicleFavouriteScreenState extends State<VehicleFavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      // Get.find<FavouriteController>().getFavouriteList();
      Get.find<TaxiFavouriteController>().getFavouriteTaxiList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'favourite'.tr, backButton: false),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn() ? SafeArea(child: Column(children: [

        SizedBox(
          width: Dimensions.webMaxWidth,
          child: Container(
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            alignment: Alignment.bottomLeft,
            child: TabBar(
              tabAlignment: ResponsiveHelper.isDesktop(context) ? TabAlignment.start : null,
              isScrollable: ResponsiveHelper.isDesktop(context) ? true : false,
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              tabs: [
                Tab(text: 'vehicles'.tr),
                Tab(text: 'providers'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FavouriteVehicleViewWidget(isProvider: false),
            FavouriteVehicleViewWidget(isProvider: true),
          ],
        )),

      ])) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }
}
