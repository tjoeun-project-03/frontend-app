// lib/services/license_service.dart
import 'package:dio/dio.dart';
import 'package:jimline/services/common/api_service.dart';

class LicenseService {
  // ApiService에 이미 설정된 dio 인스턴스를 그대로 사용합니다.
  final Dio _dio = ApiService().dio;

  Future<Map<String, dynamic>> verifyLicense(String imagePath) async {
    try {
      final String pythonUrl = "http://192.168.219.106:8000/api/v1/license/verify";

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imagePath, filename: "license.jpg"),
        "transport_type": "2", // 화물운송종사자 자격증
      });

      // 🚀 해당 요청만 60초간 기다리도록 개별 옵션 설정
      Response response = await _dio.post(
        pythonUrl,
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200) {
        return response.data; // {"status": "success", ...}
      } else {
        return {"status": "fail", "message": "서버 응답 오류"};
      }
    } catch (e) {
      print("자격증 검증 에러: $e");
      return {"status": "error", "message": "연결 실패: $e"};
    }
  }
}