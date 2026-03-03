import 'package:dio/dio.dart';
import '../common/api_service.dart';
import '../../models/shipper/reservation_model.dart';

class ReservationService {
  final Dio _dio = ApiService.getDio();

  // 화주의 예약 내역 목록 가져오기
  Future<List<ReservationModel>> getReservations() async {
    try {
      final response = await _dio.get('/api/orders/my');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ReservationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("[ReservationService] getReservations Error: $e");
      rethrow;
    }
  }
}
