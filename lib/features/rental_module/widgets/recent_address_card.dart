import 'package:flutter/material.dart';
import 'package:sixam_mart/util/styles.dart';
import '../../../util/dimensions.dart';
import '../domain/models/recent_address_model.dart';

class RecentAddressCard extends StatelessWidget {

  final RecentAddressModel recentAddressModel;

  const RecentAddressCard({super.key, required this.recentAddressModel});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: (){},
        child: Row(children: [

          Padding(padding: const EdgeInsets.only(right: 18, left: Dimensions.paddingSizeDefault),
            child: Container(height: 20, width: 20,
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                child: Icon(recentAddressModel.logo, color: Theme.of(context).primaryColor, size: Dimensions.fontSizeSmall)
            ),
          ),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(recentAddressModel.place ?? '', style: robotoRegular.copyWith(fontSize: 12)),
            Text(recentAddressModel.address ?? '', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey))

          ])
        ]),
      ),
    );
  }
}
