import 'package:dio/dio.dart';
import '../common/api_service.dart';
import '../../models/shipper/inquiry_model.dart';

class InquiryService {
  final Dio _dio = ApiService.getDio();

  // 1:1 문의 목록 가져오기
  Future<List<InquiryModel>> getInquiries() async {
    try {
      final response = await _dio.get('/api/inquiries/my');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => InquiryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("[InquiryService] getInquiries Error: $e");
      rethrow;
    }
  }

  // 1:1 문의 등록하기 (category 필드 추가)
  Future<bool> createInquiry(String title, String content, String category) async {
    try {
      final response = await _dio.post('/api/inquiries', data: {
        "title": title,
        "content": content,
        "category": category,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("[InquiryService] createInquiry Error: $e");
      return false;
    }
  }
}
