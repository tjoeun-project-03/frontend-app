import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;
  final _storage = const FlutterSecureStorage();
  
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:8080",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

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
          // 1. 이미 재시도한 요청이거나 401이 아니면 통과
          if (error.response?.statusCode != 401 || error.requestOptions.extra['is_retry'] == true) {
            if (error.response?.statusCode == 401) {
              print("🚫 [ApiService] 재시도 실패 또는 루프 차단. 로그아웃 처리.");
              await logout();
            }
            return handler.next(error);
          }

          print("🚨 [ApiService] 401 에러 감지: ${error.requestOptions.path}");

          // 2. 토큰 갱신 (한 번에 하나만 수행)
          // if (!_isRefreshing) {
          //   _isRefreshing = true;
          //   _refreshCompleter = Completer<void>();
          //
          //   final bool refreshed = await _refreshToken();
          //
          //   _isRefreshing = false;
          //   _refreshCompleter?.complete();
          //
          //   if (!refreshed) {
          //     print("❌ [ApiService] 토큰 갱신 최종 실패");
          //     await logout();
          //     return handler.next(error);
          //   }
          // } else {
          //   print("⏳ [ApiService] 다른 요청이 갱신 중... 대기");
          //   await _refreshCompleter?.future;
          // }
          //
          // // 3. 갱신된 토큰으로 재시도
          // try {
          //   final newToken = await _storage.read(key: 'access_token');
          //   final options = error.requestOptions;
          //
          //   // 헤더 업데이트 및 재시도 플래그 설정
          //   options.headers['Authorization'] = 'Bearer $newToken';
          //   options.extra['is_retry'] = true;
          //
          //   print("🔄 [ApiService] 새 토큰으로 재시도 시작: ${options.path}");
          //
          //   // 기존 dio 인스턴스로 다시 요청 (인터셉터를 다시 타게 됨)
          //   final response = await dio.request(
          //     options.path,
          //     data: options.data,
          //     queryParameters: options.queryParameters,
          //     options: Options(
          //       method: options.method,
          //       headers: options.headers,
          //       extra: options.extra,
          //     ),
          //   );
          //   return handler.resolve(response);
          // } catch (e) {
          //   print("💀 [ApiService] 재시도 중 예외 발생: $e");
          //   return handler.next(error);
          // }
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // 갱신 전용 별도 Dio (인터셉터 무한 루프 방지)
      final refreshDio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
      final response = await refreshDio.post(
        "/api/auth/refresh",
        data: refreshToken,
        options: Options(contentType: Headers.textPlainContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccess = data['accessToken'] ?? data['token'];
        final newRefresh = data['refreshToken'];

        if (newAccess != null) {
          await _storage.write(key: 'access_token', value: newAccess);
          if (newRefresh != null) {
            await _storage.write(key: 'refresh_token', value: newRefresh);
          }
          print("✨ [ApiService] 토큰 갱신 성공");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ [ApiService] 리프레시 요청 에러: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');
    print("🚩 [ApiService] 세션 종료");
  }

  FlutterSecureStorage getStorage() => _storage;
  static Dio getDio() => ApiService().dio;
}
