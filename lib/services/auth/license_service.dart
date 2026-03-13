import 'package:dio/dio.dart';

class LicenseService {
  // 🚀 인터셉터(401 처리 등)가 없는 순수한 Dio 인스턴스 사용
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> verifyLicense(String imagePath) async {
    try {
      // 🚀 AWS 주소로 변경 (8000 포트)
      final String pythonUrl = "http://52.204.62.127:8000/api/v1/license/verify";

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imagePath, filename: "license.jpg"),
        "transport_type": "2",
      });

      Response response = await _dio.post(
        pythonUrl,
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        }
        return {"status": "fail", "message": "잘못된 서버 응답 형식"};
      } else {
        return {"status": "fail", "message": "서버 응답 오류: ${response.statusCode}"};
      }
    } catch (e) {
      print("자격증 검증 에러: $e");
      return {"status": "error", "message": "연결 실패"};
    }
  }
}
