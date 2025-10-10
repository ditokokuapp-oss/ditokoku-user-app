import 'package:flutter/material.dart';
import 'package:sixam_mart/features/rental_module/custom/custom_icon_layout.dart';
import 'package:sixam_mart/util/styles.dart';
import '../../../util/dimensions.dart';
import '../domain/models/recent_address_model.dart';

class PopularDestinationCard extends StatelessWidget {

  final RecentAddressModel recentAddressModel;

  const PopularDestinationCard({super.key, required this.recentAddressModel});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: (){},
        child: Row(children: [

          const Padding(padding: EdgeInsets.only(right: 18, left: Dimensions.paddingSizeDefault),
            child: CustomIconLayout(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, icon: Icons.navigation)
          ),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(recentAddressModel.place ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            Text(recentAddressModel.address ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey))

          ])
        ]),
      ),
    );
  }
}
