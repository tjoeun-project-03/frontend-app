import 'package:dio/dio.dart';
import '../common/api_service.dart';
import '../../models/shipper/notice_model.dart';

class NoticeService {
  final Dio _dio = ApiService.getDio();

  // 공지사항 목록 가져오기
  Future<List<NoticeModel>> getNotices() async {
    try {
      final response = await _dio.get('/api/notices'); 
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => NoticeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("🚨 [NoticeService] getNotices Error: $e");
      rethrow;
    }
  }
}
