import 'package:flutter/material.dart';

class SavedAddressModel{
  final IconData? logo;
  final String? place;
  final String? address;

  const SavedAddressModel({
    required this.logo,
    required this.place,
    required this.address
  });
}