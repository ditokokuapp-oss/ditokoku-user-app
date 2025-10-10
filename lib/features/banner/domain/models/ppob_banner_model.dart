class PpobBannerModel {
  final int id;
  final String namaBanner;
  final String url;
  final int isActive;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fName;
  final String? lName;

  PpobBannerModel({
    required this.id,
    required this.namaBanner,
    required this.url,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.fName,
    this.lName,
  });

  factory PpobBannerModel.fromJson(Map<String, dynamic> json) {
    return PpobBannerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaBanner: json['nama_banner'] ?? '',
      url: json['url'] ?? '', // ✅ Langsung ambil URL full dari response
      isActive: json['is_active'] is int ? json['is_active'] : int.parse(json['is_active'].toString()),
      createdBy: json['created_by'] != null 
          ? (json['created_by'] is int ? json['created_by'] : int.parse(json['created_by'].toString()))
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fName: json['f_name'],
      lName: json['l_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_banner': namaBanner,
      'url': url,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'f_name': fName,
      'l_name': lName,
    };
  }
}

class PpobBannerResponse {
  final bool status;
  final String message;
  final List<PpobBannerModel> data;

  PpobBannerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PpobBannerResponse.fromJson(Map<String, dynamic> json) {
    return PpobBannerResponse(
      status: json['status'] == true || json['status'] == 1,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? (json['data'] as List).map((item) => PpobBannerModel.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}