import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';

import '../../../util/styles.dart';

class VehicleGridItem extends StatelessWidget {

  final String label;
  final String? assetImage;

  const VehicleGridItem({super.key, required this.label, this.assetImage});

  @override
  Widget build(BuildContext context) {
    return Row(children: [

      Image.asset(assetImage!, height: 16, width: 16, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
      const SizedBox(width: 8),

      Flexible(child: Text(
        label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
      )),

    ]);
  }
}
