import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import '../../../../../../util/styles.dart';
import '../../domain/models/my_address_model_new.dart';

class MyAddressCard extends StatelessWidget {

  final MyAddressModelNew myAddressModelNew;

  const MyAddressCard({super.key, required this.myAddressModelNew,});

  @override
  Widget build(BuildContext context) {
    return Container(width: 196, height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(children: [

        Icon(myAddressModelNew.icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('${myAddressModelNew.title}', style: robotoMedium.copyWith(fontSize: 12, color: Colors.black87)),
              const SizedBox(height: 3),

              Text('${myAddressModelNew.address}',
                style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          )],
      ),
    );
  }
}