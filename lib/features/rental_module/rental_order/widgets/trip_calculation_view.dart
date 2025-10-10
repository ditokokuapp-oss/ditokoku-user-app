import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/widgets/bill_details_widget.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class TripCalculationView extends StatelessWidget {
  final double tripCost;
  final double discount;
  final double couponDiscount;
  final double subTotal;
  final double tax;
  final double total;
  final double serviceFee;
  final bool isCompleted;
  final bool? taxInclude;
  final double? taxPercent;
  final double? walletPay;
  final double? duePay;
  const TripCalculationView({
    super.key, required this.tripCost, required this.discount, required this.couponDiscount, required this.subTotal,
    required this.tax, required this.total, this.isCompleted = false, required this.serviceFee, this.taxInclude,
    this.taxPercent, this.walletPay, this.duePay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 15),
      child: Column(children: [

        BillDetailsWidget(
          tripCost: tripCost,
          tripDiscountCost: discount,
          couponDiscountCost: couponDiscount,
          serviceFee: serviceFee,
          subtotal: subTotal,
          vat: tax,
          isCompleted: isCompleted,
          taxPercent: taxPercent,
          taxInclude: taxInclude,
        ),
        const Divider(),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('total'.tr, style: robotoMedium),
          Text(PriceConverter.convertPrice(total, forTaxi: true), style: robotoMedium, textDirection: TextDirection.ltr),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if(walletPay != null && walletPay! > 0)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('wallet_payment'.tr, style: robotoRegular),
          Text('- ${PriceConverter.convertPrice(0)}', style: robotoRegular, textDirection: TextDirection.ltr),
        ]),
        SizedBox(height: (walletPay != null && walletPay! > 0) ?Dimensions.paddingSizeSmall : 0),

        if(duePay != null && duePay! > 0)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('due_payment'.tr, style: robotoRegular),
          Text('- ${PriceConverter.convertPrice(0)}', style: robotoRegular, textDirection: TextDirection.ltr),
        ]),

      ]),
    );
  }
}
