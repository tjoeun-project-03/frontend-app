import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();

  // 싱글톤 패턴
  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.219.106:8080",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 🚀 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // ⚠️ 401 에러 발생 시 로그
          if (error.response?.statusCode == 401) {
            print("🚨 [401 Unauthorized] 토큰 만료 감지. 갱신을 시도합니다...");

            final bool refreshed = await _refreshToken();

            if (refreshed) {
              print("✅ [Auth] 토큰 갱신 성공! 원래 요청을 재시도합니다: ${error.requestOptions.path}");
              String? newToken = await _storage.read(key: 'access_token');
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // 재시도 시에도 dio 인스턴스를 사용하여 인터셉터가 적용되도록 함
              return handler.resolve(await dio.fetch(error.requestOptions));
            } else {
              print("❌ [Auth] 토큰 갱신 실패. 로그아웃 처리합니다.");
              await logout();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // 🚀 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await _storage.read(key: 'refresh_token');
      print("🔍 [Refresh] 저장된 리프레시 토큰 읽기 완료");

      if (refreshToken == null) {
        print("⚠️ [Refresh] 저장된 리프레시 토큰이 없습니다.");
        return false;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: "http://10.0.2.2:8080",
        contentType: Headers.textPlainContentType, // 서버 @RequestBody String에 맞춤
      ));

      print("📡 [Refresh] 서버에 재발급 요청 중...");
      final response = await refreshDio.post(
        "/api/auth/refresh",
        data: refreshToken,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // 서버 응답 필드명이 'accessToken'인지 확인하세요.
        await _storage.write(key: 'access_token', value: data['accessToken']);
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);
          print("💾 [Refresh] 새로운 리프레시 토큰 저장 완료");
        }

        print("✨ [Refresh] 엑세스 토큰 갱신 완료!");
        return true;
      }

      print("❓ [Refresh] 서버 응답이 200이 아님: ${response.statusCode}");
      return false;
    } catch (e) {
      // 400 에러 발생 시 로그를 통해 서버의 거절 이유를 확인합니다.
      if (e is DioException) {
        print("❌ 토큰 갱신 실패 응답: ${e.response?.data}");
      }
      return false;
    }
  }

  // 🚀 로그아웃 처리
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');
    // 필요시 GoRouter로 로그인 화면으로 이동하도록 처리
  }

  // 🚀 Storage 접근 (토큰 저장용)
  FlutterSecureStorage getStorage() {
    return _storage;
  }

  // 🚀 Dio 인스턴스 반환
  static Dio getDio() {
    return ApiService().dio;
  }
}
