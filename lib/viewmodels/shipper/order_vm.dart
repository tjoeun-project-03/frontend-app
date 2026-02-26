import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderViewModel extends StateNotifier<bool> {
  OrderViewModel() : super(false);

  final _storage = const FlutterSecureStorage();

  // 🚀 스프링 서버로 주문 생성 요청
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    state = true; // 로딩 시작
    final token = await _storage.read(key: 'access_token');

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/orders"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(orderData),
      );

      state = false; // 로딩 종료
      return response.statusCode == 200;
    } catch (e) {
      state = false;
      return false;
    }
  }
}

final orderViewModelProvider = StateNotifierProvider<OrderViewModel, bool>((ref) => OrderViewModel());