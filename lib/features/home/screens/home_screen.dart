import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_dialog_widget.dart';
import 'package:sixam_mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    if(AuthHelper.isLoggedIn()) {
      Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
    }
    if(Get.find<SplashController>().module != null && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel! && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isTaxi!) {
      Get.find<BannerController>().getBannerList(reload);
      Get.find<StoreController>().getRecommendedStoreList();
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<ItemController>().getDiscountedItemList(reload, false, 'all');
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
    }
    if(AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if(Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();
  bool _isLoadingLocation = false;
  bool _isLoadingData = true;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isMonitoring = false;

  String _formatAddress(String? address, {int maxWords = 5}) {
    if (address == null || address.isEmpty) return "Tap untuk set lokasi";
    
    final words = address.split(" ");
    if (words.length <= maxWords) return address;
    
    return "${words.take(maxWords).join(" ")}...";
  }

  @override
  void initState() {
    super.initState();
    
    // Auto load data dengan retry mechanism
    _loadDataWithRetry();

    // Auto-detect dan set location kalau belum ada
    _checkAndSetLocationAutomatically();
    
    // Monitor moduleList setiap 3 detik
    _startModuleMonitoring();

    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
  }

  Future<void> _loadDataWithRetry() async {
    setState(() {
      _isLoadingData = true;
      _retryCount = 0;
    });

    while (_retryCount < _maxRetries) {
      try {
        print('Loading data... attempt ${_retryCount + 1}');
        
        await HomeScreen.loadData(true);
        
        // Tunggu sebentar untuk memastikan data sudah ter-update di controller
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check apakah moduleList ada dan tidak kosong
        final splashController = Get.find<SplashController>();
        if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
          throw Exception('Module list is empty or null');
        }
        
        // Check jika refer bottom sheet perlu ditampilkan
        Get.find<SplashController>().getReferBottomSheetStatus();
        if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount??false) && 
           Get.find<SplashController>().showReferBottomSheet) {
          _showReferBottomSheet();
        }

        // Data berhasil dimuat
        setState(() {
          _isLoadingData = false;
        });
        print('Data loaded successfully with ${splashController.moduleList!.length} modules');
        break;
        
      } catch (e) {
        _retryCount++;
        print('Error loading data (attempt $_retryCount): $e');
        
        if (_retryCount >= _maxRetries) {
          // Sudah mencapai max retry
          setState(() {
            _isLoadingData = false;
          });
          
          // Tampilkan error message
          Get.snackbar(
            'Error',
            'Gagal memuat data setelah $_maxRetries percobaan. Silakan refresh halaman.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          break;
        }
        
        // Tunggu sebelum retry
        print('Retrying in ${_retryCount * 2} seconds...');
        await Future.delayed(Duration(seconds: _retryCount * 2));
      }
    }
  }

  Future<void> _checkAndSetLocationAutomatically() async {
    print('Checking if location needs to be set automatically...');
    
    final userAddress = AddressHelper.getUserAddressFromSharedPref();
    
    if (userAddress == null) {
      print('No address found, setting dummy location and getting real location...');
      
      // 1. Set dummy location dulu biar UI bisa load
      await _setDummyLocation();
      
      // 2. Ambil real location di background
      _getRealLocationInBackground();
    } else {
      print('Address exists: ${userAddress.address}');
      
      // Safe zone check dengan existing address
      if (!ResponsiveHelper.isWeb() && userAddress.latitude != null && userAddress.longitude != null) {
        Get.find<LocationController>().getZone(
            userAddress.latitude!,
            userAddress.longitude!, false, updateInAddress: true
        );
      }
    }
  }

  Future<void> _setDummyLocation() async {
    try {
      print('Setting dummy Jakarta location...');
      
      // Dummy location Jakarta
      AddressModel dummyAddress = AddressModel(
        latitude: '-6.2088',
        longitude: '106.8456',
        address: 'Jakarta, Indonesia',
        addressType: 'others',
        zoneId: 1,
        zoneIds: [1],
        contactPersonName: 'User',
        contactPersonNumber: '123456789',
      );
      
      // Save dummy location
      bool saved = await AddressHelper.saveUserAddressInSharedPref(dummyAddress);
      
      if (saved) {
        print('Dummy location set successfully');
        setState(() {}); // Refresh UI
      } else {
        print('Failed to save dummy location');
      }
    } catch (e) {
      print('Error setting dummy location: $e');
    }
  }

  void _getRealLocationInBackground() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      print('Getting real location in background...');
      LocationController locationController = Get.find<LocationController>();
      
      // Ambil current location real
      AddressModel realAddress = await locationController.getCurrentLocation(true);
      
      if (realAddress.latitude != null && realAddress.longitude != null) {
        // Save real location
        bool saved = await AddressHelper.saveUserAddressInSharedPref(realAddress);
        
        if (saved) {
          print('Real location updated: ${realAddress.address}');
          setState(() {
            _isLoadingLocation = false;
          }); // Update UI dengan location real
        }
      }
    } catch (e) {
      print('Error getting real location: $e');
      // Tetap pakai dummy location, gak masalah
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _isMonitoring = false;
  }

  void _startModuleMonitoring() {
    _isMonitoring = true;
    _checkModuleListPeriodically();
  }

  Future<void> _checkModuleListPeriodically() async {
    while (_isMonitoring && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted || !_isMonitoring) break;
      
      final splashController = Get.find<SplashController>();
      
      // Jika moduleList null atau kosong, dan tidak sedang loading
      if ((splashController.moduleList == null || splashController.moduleList!.isEmpty) && !_isLoadingData) {
        print('Module list is empty, auto refreshing...');
        _loadDataWithRetry();
      }
    }
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async{
   try {
     await Get.find<TaxiHomeController>().getTaxiBannerList(true);
   } catch (e) {
     print('Error loading taxi banner: $e');
   }
   
   try {
     await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
   } catch (e) {
     print('Error loading top rated cars: $e');
   }
   
    if (AuthHelper.isLoggedIn()) {
      try {
        await Get.find<AddressController>().getAddressList();
      } catch (e) {
        print('Error loading address list: $e');
      }
      
      try {
        await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      } catch (e) {
        print('Error loading taxi coupons: $e');
      }
      
      try {
        await Get.find<TaxiCartController>().getCarCartList();
      } catch (e) {
        print('Error loading car cart list: $e');
        // Silent error - jangan tampilkan alert
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if(splashController.moduleList != null && splashController.moduleList!.length == 1) {
        splashController.switchModule(0, true);
      }
      bool showMobileModule = !ResponsiveHelper.isDesktop(context) && splashController.module == null && splashController.configModel!.module == null;
      bool isParcel = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.parcel;
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ecommerce;
      bool isGrocery = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.grocery;
      bool isTaxi = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.taxi;

      return GetBuilder<HomeController>(builder: (homeController) {
        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
         extendBodyBehindAppBar: true, // ✅ Tambahkan ini di atas body
backgroundColor: Theme.of(context).colorScheme.surface,

          
          body: isParcel ? const ParcelCategoryScreen() : SafeArea(
              top: false,
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadDataWithRetry();
              },
              child: Stack(
                children: [
                  Container(
                    height: 200,
                  ),
                  ResponsiveHelper.isDesktop(context) ? WebNewHomeScreen(
                    scrollController: _scrollController,
                  ) : CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Langsung mulai dari Search Bar (tanpa AppBar)
                      
                      // Search Bar (untuk non-module & non-taxi screen)
                      !showMobileModule && !isTaxi ? SliverPersistentHeader(
                        pinned: false,
                        delegate: SliverDelegate(callback: (val){}, child: Center(child: Container(
                          height: 50, width: Dimensions.webMaxWidth,
                          color: searchBgShow ? Get.find<ThemeController>().darkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor : null,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).primaryColor.withAlpha(50), width: 1),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                              ),
                              child: Row(children: [
                                Icon(
                                  CupertinoIcons.search, size: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Expanded(child: Text(
                                  Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                                  ),
                                )),
                              ]),
                            ),
                          ),
                        ))),
                      ) : const SliverToBoxAdapter(),

                      // KONTEN UTAMA (Module View atau Module-specific screens)
                      SliverToBoxAdapter(
                        child: Center(child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: !showMobileModule ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            isGrocery ? const GroceryHomeScreen()
                                : isPharmacy ? const PharmacyHomeScreen()
                                : isFood ? const FoodHomeScreen()
                                : isShop ? const ShopHomeScreen()
                                : isTaxi ? const TaxiHomeScreen()
                                : const SizedBox(),
                          ]) : ModuleView(
                            splashController: splashController,
                            isLoading: _isLoadingData,
                          ),
                        )),
                      ),

                      // Filter widget (untuk non-module & non-taxi screen)
                      !showMobileModule && !isTaxi ? SliverPersistentHeader(
                        key: _headerKey,
                        pinned: true,
                        delegate: SliverDelegate(
                          height: 85,
                          callback: (val) {
                            searchBgShow = val;
                          },
                          child: const AllStoreFilterWidget(),
                        ),
                      ) : const SliverToBoxAdapter(),

                      // Store list (untuk non-module & non-taxi screen)
                      SliverToBoxAdapter(child: !showMobileModule && !isTaxi ? Center(child: GetBuilder<StoreController>(builder: (storeController) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                          child: PaginatedListView(
                            scrollController: _scrollController,
                            totalSize: storeController.storeModel?.totalSize,
                            offset: storeController.storeModel?.offset,
                            onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                            itemView: ItemsView(
                              isStore: true,
                              items: null,
                              isFoodOrGrocery: (isFood || isGrocery),
                              stores: storeController.storeModel?.stores,
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                                vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                              ),
                            ),
                          ),
                        );
                      }),) : const SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: AuthHelper.isLoggedIn() && homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty ?
          homeController.showFavButton ? Padding(
            padding: EdgeInsets.only(bottom: 50.0, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
            child: InkWell(
              onTap: () => Get.dialog(const CashBackDialogWidget()),
              child: const CashBackLogoWidget(),
            ),
          ) : null : null,
        );
      });
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent;
    callback!(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}