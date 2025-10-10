import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/html/controllers/html_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../util/styles.dart';

class CheckoutTermsAndCondition extends StatefulWidget {
  const CheckoutTermsAndCondition({super.key});

  @override
  State<CheckoutTermsAndCondition> createState() => _CheckoutTermsAndConditionState();
}

class _CheckoutTermsAndConditionState extends State<CheckoutTermsAndCondition> {

  @override
  void initState() {
    super.initState();

    if(Get.find<HtmlController>().htmlText == null) {
      Get.find<HtmlController>().getHtmlText(HtmlType.termsAndCondition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 33, height: 4.0,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),

        //cross icon
        Container(
          padding: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.close, size: 24, color: Colors.grey[300],),
          ),
        ),

        Text('terms_and_conditions'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Expanded(
          child: GetBuilder<HtmlController>(builder: (htmlController) {
            return Center(
              child: /*htmlController.htmlText != null ? */SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                child: HtmlWidget(
                  htmlController.htmlText ?? '',
                  key: Key(HtmlType.termsAndCondition.toString()),
                  textStyle: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
                  onTapUrl: (String url){
                    return launchUrlString(url);
                  },
                ),
              ) /*: const CircularProgressIndicator()*/,
            );
          }),
        ),

      ]),
    );
  }
}
