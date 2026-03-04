import 'dart:convert';

class FavoriteAddressModel {
  final String id;
  final String alias; // 주소 별명 (예: 우리집, 회사)
  final String address; // 도로명/지번 주소
  final String detailAddress; // 상세 주소

  FavoriteAddressModel({
    required this.id,
    required this.alias,
    required this.address,
    required this.detailAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'address': address,
      'detailAddress': detailAddress,
    };
  }

  factory FavoriteAddressModel.fromMap(Map<String, dynamic> map) {
    return FavoriteAddressModel(
      id: map['id'] ?? '',
      alias: map['alias'] ?? '',
      address: map['address'] ?? '',
      detailAddress: map['detailAddress'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FavoriteAddressModel.fromJson(String source) =>
      FavoriteAddressModel.fromMap(json.decode(source));
}
