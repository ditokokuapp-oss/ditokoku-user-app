import 'package:flutter/material.dart';

class RecentAddressModel{
  final IconData? logo;
  final String? place;
  final String? address;

  const RecentAddressModel({
    required this.logo,
    required this.place,
    required this.address
  });
}