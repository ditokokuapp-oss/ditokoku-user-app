import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/ppob_banner_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/banner/domain/services/banner_service_interface.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;
  
  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;
  
  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;
  
  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;
  
  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;
  
  List<dynamic>? _featuredBannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  ParcelOtherBannerModel? _parcelOtherBannerModel;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;
  
  PromotionalBanner? _promotionalBanner;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  // ✅ PPOB Banner Properties
  List<PpobBannerModel>? _ppobBannerList;
  List<PpobBannerModel>? get ppobBannerList => _ppobBannerList;

  bool _isLoadingPpobBanner = false;
  bool get isLoadingPpobBanner => _isLoadingPpobBanner;

  Future<void> getFeaturedBanner() async {
    BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
    if (bannerModel != null) {
      _featuredBannerList = [];
      _featuredBannerDataList = [];

      List<int?> moduleIdList = bannerServiceInterface.moduleIdList();

      for (var campaign in bannerModel.campaigns!) {
        if(_featuredBannerList!.contains(campaign.imageFullUrl)) {
          _featuredBannerList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _featuredBannerList!.add(campaign.imageFullUrl);
        }
        _featuredBannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_featuredBannerList!.contains(banner.imageFullUrl)) {
          _featuredBannerList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _featuredBannerList!.add(banner.imageFullUrl);
        }
        if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
          _featuredBannerDataList!.add(banner.item);
        }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
          _featuredBannerDataList!.add(banner.store);
        }else if(banner.type == 'default') {
          _featuredBannerDataList!.add(banner.link);
        }else{
          _featuredBannerDataList!.add(null);
        }
      }
    }
    update();
  }

  void clearBanner() {
    _bannerImageList = null;
  }

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(reload) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel);

        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBanner(bannerModel);
      }

    }
  }

  _prepareBanner(BannerModel? bannerModel) async{
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if(_bannerImageList!.contains(campaign.imageFullUrl)) {
          _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _bannerImageList!.add(campaign.imageFullUrl);
        }
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {

        if(_bannerImageList!.contains(banner.imageFullUrl)) {
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(banner.imageFullUrl);
        }

        if(banner.item != null) {
          _bannerDataList!.add(banner.item);
        }else if(banner.store != null){
          _bannerDataList!.add(banner.store);
        }else if(banner.type == 'default'){
          _bannerDataList!.add(banner.link);
        }else{
          _bannerDataList!.add(null);
        }
      }
    }
    update();
  }

  Future<void> getTaxiBannerList(bool reload) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
      if (bannerModel != null) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.imageFullUrl);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.imageFullUrl);
          if(banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _taxiBannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _taxiBannerDataList!.add(banner.link);
          }else{
            _taxiBannerDataList!.add(null);
          }
        }
        if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }
      }
      update();
    }
  }

  Future<void> getParcelOtherBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_parcelOtherBannerModel == null || reload || fromRecall) {
      ParcelOtherBannerModel? parcelOtherBannerModel;
      if(dataSource == DataSourceEnum.local) {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
        getParcelOtherBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
      }
    }
  }

  _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
    if (parcelOtherBannerModel != null) {
      _parcelOtherBannerModel = parcelOtherBannerModel;
    }
    update();
  }

  Future<void> getPromotionalBannerList(bool reload) async {
    if(_promotionalBanner == null || reload) {
      PromotionalBanner? promotionalBanner = await bannerServiceInterface.getPromotionalBannerList();
      if (promotionalBanner != null) {
        _promotionalBanner = promotionalBanner;
      }
      update();
    }
  }


Future<void> getPpobBannerList(bool reload) async {
  print('🟢 getPpobBannerList called with reload: $reload');
  print('🟢 Current state - _ppobBannerList: $_ppobBannerList, reload: $reload');
  
  if (_ppobBannerList == null || reload) {
    print('🟡 Setting loading to true...');
    _isLoadingPpobBanner = true;
    update(); // ✅ Penting: update dulu biar UI tahu loading

    try {
      print('🔄 Fetching PPOB banners from API...');
      
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/banners?is_active=1'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final bannerResponse = PpobBannerResponse.fromJson(jsonData);
        
        if (bannerResponse.status) {
          _ppobBannerList = bannerResponse.data;
          print('✅ Banner loaded: ${_ppobBannerList?.length} items');
          
          // Print setiap URL banner
          for (var banner in _ppobBannerList!) {
            print('🖼️ Banner URL: ${banner.url}');
          }
        } else {
          _ppobBannerList = [];
          print('❌ Banner status false');
        }
      } else {
        _ppobBannerList = [];
        print('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading PPOB banners: $e');
      print('Stack trace: $stackTrace');
      _ppobBannerList = [];
    } finally {
      print('🟢 Setting loading to false...');
      _isLoadingPpobBanner = false;
      update(); // ✅ Penting: update lagi setelah selesai
      print('🟢 Update called - _isLoadingPpobBanner: $_isLoadingPpobBanner');
    }
  } else {
    print('⚪ Skip loading - banner already loaded');
  }
}

  // ✅ Clear PPOB Banner
  void clearPpobBanner() {
    _ppobBannerList = null;
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }
  
}