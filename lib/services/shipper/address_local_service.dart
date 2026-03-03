import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/shipper/favorite_address_model.dart';

class AddressLocalService {
  final _storage = const FlutterSecureStorage();
  final String _storageKey = 'favorite_addresses';

  // 모든 자주 쓰는 주소 가져오기
  Future<List<FavoriteAddressModel>> getFavoriteAddresses() async {
    try {
      String? jsonString = await _storage.read(key: _storageKey);
      if (jsonString == null) return [];

      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => FavoriteAddressModel.fromMap(item)).toList();
    } catch (e) {
      print("🚨 [AddressLocalService] get Error: $e");
      return [];
    }
  }

  // 주소 리스트 저장하기
  Future<void> saveFavoriteAddresses(List<FavoriteAddressModel> addresses) async {
    try {
      List<Map<String, dynamic>> jsonList = addresses.map((a) => a.toMap()).toList();
      String jsonString = json.encode(jsonList);
      await _storage.write(key: _storageKey, value: jsonString);
    } catch (e) {
      print("🚨 [AddressLocalService] save Error: $e");
    }
  }
}
