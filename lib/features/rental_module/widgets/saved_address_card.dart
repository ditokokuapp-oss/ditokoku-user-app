import 'package:flutter/material.dart';
import 'package:sixam_mart/features/rental_module/domain/models/saved_address_model.dart';import '../../../../util/styles.dart';
import '../../../util/dimensions.dart';

class SavedAddressCard extends StatelessWidget {
  final SavedAddressModel savedAddressModel;

  const SavedAddressCard({super.key, required this.savedAddressModel});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Padding(padding: const EdgeInsets.only(top: 13, left: Dimensions.paddingSizeLarge),
        child: InkWell(
          onTap: (){},
          child: Row(children: [

            Icon(savedAddressModel.logo, color: Theme.of(context).primaryColor, size: Dimensions.fontSizeSmall),
            const SizedBox(width: Dimensions.paddingSizeLarge),

            Text(savedAddressModel.place ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

            Text(savedAddressModel.address ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey))

          ]),
        ),
      )
    ]);
  }
}
