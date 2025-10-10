class TaxiCouponModel {
  int? id;
  String? title;
  String? code;
  String? startDate;
  String? expireDate;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  String? couponType;
  int? limit;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? data;
  int? totalUses;
  int? moduleId;
  String? createdBy;
  String? customerId;
  String? slug;
  int? storeId;
  int? zoneId;
  Store? store;
  List<Translations>? translations;

  TaxiCouponModel({
    this.id,
    this.title,
    this.code,
    this.startDate,
    this.expireDate,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.couponType,
    this.limit,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.totalUses,
    this.moduleId,
    this.createdBy,
    this.customerId,
    this.slug,
    this.storeId,
    this.zoneId,
    this.store,
    this.translations,
  });

  TaxiCouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase']?.toDouble();
    maxDiscount = json['max_discount']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    couponType = json['coupon_type'];
    limit = json['limit'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    data = json['data'];
    totalUses = json['total_uses'];
    moduleId = json['module_id'];
    createdBy = json['created_by'];
    customerId = json['customer_id'];
    slug = json['slug'];
    storeId = json['store_id'];
    zoneId = json['zone_id'];
    store = json['store'] != null ? Store.fromJson(json['store']) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['start_date'] = startDate;
    data['expire_date'] = expireDate;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['coupon_type'] = couponType;
    data['limit'] = limit;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['data'] = this.data;
    data['total_uses'] = totalUses;
    data['module_id'] = moduleId;
    data['created_by'] = createdBy;
    data['customer_id'] = customerId;
    data['slug'] = slug;
    data['store_id'] = storeId;
    data['zone_id'] = zoneId;
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Store {
  int? id;
  String? name;
  bool? gstStatus;
  String? gstCode;
  String? logoFullUrl;
  String? coverPhotoFullUrl;
  String? metaImageFullUrl;
  List<Translations>? translations;
  List<Storage>? storage;

  Store({
    this.id,
    this.name,
    this.gstStatus,
    this.gstCode,
    this.logoFullUrl,
    this.coverPhotoFullUrl,
    this.metaImageFullUrl,
    this.translations,
    this.storage,
  });

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    logoFullUrl = json['logo_full_url'];
    coverPhotoFullUrl = json['cover_photo_full_url'];
    metaImageFullUrl = json['meta_image_full_url'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['logo_full_url'] = logoFullUrl;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['meta_image_full_url'] = metaImageFullUrl;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations({
    this.id,
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage({
    this.id,
    this.dataType,
    this.dataId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
