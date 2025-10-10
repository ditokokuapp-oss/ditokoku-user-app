class TaxiProviderReviewModel {
  int? totalSize;
  int? limit;
  int? offset;
  Provider? provider;
  List<Reviews>? reviews;

  TaxiProviderReviewModel(
      {this.totalSize, this.limit, this.offset, this.provider, this.reviews});

  TaxiProviderReviewModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Provider {
  String? name;
  List<int>? ratings;
  double? avgRating;
  int? ratingCount;

  Provider({this.name, this.ratings, this.avgRating, this.ratingCount});

  Provider.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    ratings = json['ratings'].cast<int>();
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['ratings'] = ratings;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    return data;
  }
}

class Reviews {
  int? id;
  int? providerId;
  int? moduleId;
  int? userId;
  int? tripId;
  int? vehicleId;
  int? vehicleIdentityId;
  int? rating;
  String? comment;
  List<Null>? attachment;
  int? status;
  String? reply;
  String? reviewId;
  String? repliedAt;
  String? createdAt;
  String? updatedAt;
  String? vehicleName;
  String? vehicleImage;
  String? customerName;
  String? vehicleImageFullUrl;

  Reviews(
      {this.id,
        this.providerId,
        this.moduleId,
        this.userId,
        this.tripId,
        this.vehicleId,
        this.vehicleIdentityId,
        this.rating,
        this.comment,
        this.attachment,
        this.status,
        this.reply,
        this.reviewId,
        this.repliedAt,
        this.createdAt,
        this.updatedAt,
        this.vehicleName,
        this.vehicleImage,
        this.customerName,
        this.vehicleImageFullUrl});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    moduleId = json['module_id'];
    userId = json['user_id'];
    tripId = json['trip_id'];
    vehicleId = json['vehicle_id'];
    vehicleIdentityId = json['vehicle_identity_id'];
    rating = json['rating'];
    comment = json['comment'];
    // if (json['attachment'] != null) {
    //   attachment = <Null>[];
    //   json['attachment'].forEach((v) {
    //     attachment!.add(Null.fromJson(v));
    //   });
    // }
    status = json['status'];
    reply = json['reply'];
    reviewId = json['review_id'];
    repliedAt = json['replied_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vehicleName = json['vehicle_name'];
    vehicleImage = json['vehicle_image'];
    customerName = json['customer_name'];
    vehicleImageFullUrl = json['vehicle_image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['module_id'] = moduleId;
    data['user_id'] = userId;
    data['trip_id'] = tripId;
    data['vehicle_id'] = vehicleId;
    data['vehicle_identity_id'] = vehicleIdentityId;
    data['rating'] = rating;
    data['comment'] = comment;
    // if (attachment != null) {
    //   data['attachment'] = attachment!.map((v) => v.toJson()).toList();
    // }
    data['status'] = status;
    data['reply'] = reply;
    data['review_id'] = reviewId;
    data['replied_at'] = repliedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['vehicle_name'] = vehicleName;
    data['vehicle_image'] = vehicleImage;
    data['customer_name'] = customerName;
    data['vehicle_image_full_url'] = vehicleImageFullUrl;
    return data;
  }
}
