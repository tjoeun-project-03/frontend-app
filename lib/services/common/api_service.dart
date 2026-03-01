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
          // 1. 모든 요청에 토큰 추가
          String? token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 2. 401 Unauthorized 시 토큰 갱신 시도
          if (error.response?.statusCode == 401) {
            final bool refreshed = await _refreshToken();
            if (refreshed) {
              // 토큰 갱신 성공 후 원래 요청 재시도
              String? newToken = await _storage.read(key: 'access_token');
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              return handler.resolve(await dio.fetch(error.requestOptions));
            } else {
              // 토큰 갱신 실패 → 로그아웃 처리
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
      if (refreshToken == null) return false;

      final response = await Dio().post(
        "http://192.168.219.106:8080/api/auth/refresh",
        options: Options(headers: {
          'Authorization': 'Bearer $refreshToken',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['accessToken']);
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("토큰 갱신 실패: $e");
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

