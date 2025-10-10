import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_debounce_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/helper/string_limit_helper.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/select_vehicle_screen/widgets/search_text_field.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SearchVehicleScreen extends StatefulWidget {

  const SearchVehicleScreen({super.key});

  @override
  State<SearchVehicleScreen> createState() => _SearchVehicleScreenState();
}

class _SearchVehicleScreenState extends State<SearchVehicleScreen> {
  TextEditingController textSearchController = TextEditingController();
  final CustomDebounceWidget customDebounceWidget = CustomDebounceWidget(milliseconds: 500);
  List<String> _vehicles = <String>[];
  bool _showSuggestion = false;



  Future<void> _searchSuggestions(String query) async {
    _vehicles = [];
    if (query == '') {
      _showSuggestion = false;
      _vehicles = [];
    } else {
      _showSuggestion = true;
      _vehicles = await Get.find<TaxiHomeController>().getSearchSuggestions(query)??[];
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    Get.find<TaxiHomeController>().getSearchHistoryList();
    if(Get.find<TaxiHomeController>().popularCarSuggestionModelList != null && Get.find<TaxiHomeController>().popularCarSuggestionModelList!.isEmpty) {
      Get.find<TaxiHomeController>().getPopularSearchList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'search'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
            child: SearchTextField(
              textEditingController: textSearchController,
              hintText: "type_here_to_search_vehicle".tr,
              onIconPressed: () {
                Get.back(result: textSearchController.text);
                },
              onSubmit: (value) {

              },
              onChange: (value) {
                customDebounceWidget.run((){
                  _searchSuggestions(value);
                  // counterController.getCounterList(1, searchText: value);
                });
              },
            ),
          ),

          _showSuggestion ? searchSuggestionsView() : defaultSuggestionsView(),

        ]),
      ),
    );
  }

  Widget searchSuggestionsView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text('search_suggestions'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

        _vehicles.isNotEmpty ? ListView.builder(
          itemCount: _vehicles.length,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return CustomInkWell(
              onTap: () {
                setState(() {
                  textSearchController.text = _vehicles[index];
                });
              },
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Row(children: [

                    Icon(Icons.search, size: Dimensions.fontSizeLarge, color: Colors.grey),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(child: Text(_vehicles[index], maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)))
                  ]),
                ),

                Icon(Icons.arrow_forward, size: Dimensions.fontSizeLarge),
              ]),
            );
          },
        ) : Center(child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Text('no_suggestions_found'.tr),
        )),
      ]),
    );
  }

  Widget defaultSuggestionsView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 10)],
      ),
      child: GetBuilder<TaxiHomeController>(
          builder: (taxiHomeController) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            taxiHomeController.searchHistoryList.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('last_search'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                TextButton(
                  onPressed: () {
                    taxiHomeController.clearSearchHistory();
                  },
                  child: Text('clear_all'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.redAccent)),
                )
              ]),

              ListView.builder(
                itemCount: taxiHomeController.searchHistoryList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return CustomInkWell(
                    onTap: () {
                      setState(() {
                        textSearchController.text = taxiHomeController.searchHistoryList[index];
                      });
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(
                        child: Row(children: [

                          Icon(Icons.search, size: Dimensions.fontSizeLarge, color: Colors.grey),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Flexible(
                            child: Text(
                              taxiHomeController.searchHistoryList[index], overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                        ]),
                      ),

                      IconButton(
                        onPressed: () => taxiHomeController.removeSearchHistory(index),
                        icon: Icon(Icons.close, size: Dimensions.fontSizeLarge),
                      )
                    ]),
                  );
                },
              ),

            ]) : const SizedBox(),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            if(taxiHomeController.popularCarSuggestionModelList != null && taxiHomeController.popularCarSuggestionModelList!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text('popular_search'.tr, style: robotoBold.copyWith(fontSize: 14)),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Wrap(
                  spacing: 8, runSpacing: Dimensions.paddingSizeSmall,
                  direction: Axis.horizontal,
                  children: List.generate(taxiHomeController.popularCarSuggestionModelList!.length, (index) => CustomInkWell(
                    onTap: () {
                      setState(() {
                        textSearchController.text = taxiHomeController.popularCarSuggestionModelList![index].name!;
                      });
                    },
                    radius: Dimensions.radiusExtraLarge,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        StringLimitHelper.limitText(taxiHomeController.popularCarSuggestionModelList![index].name??'', 30),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Get.find<ThemeController>().darkTheme ? Colors.white70 : const Color(0xFF313F38)),
                      ),
                    ),
                  )),
                ),

              ]),
            ),


            const SizedBox(height: Dimensions.paddingSizeLarge),

          ]);
        }
      ),
    );
  }
}