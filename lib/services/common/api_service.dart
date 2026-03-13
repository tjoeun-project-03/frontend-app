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
        // 🚀 AWS 주소로 변경
        baseUrl: "http://52.204.62.127:8080",
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
          if (error.requestOptions.extra['is_retry'] == true) {
            print("🚫 [ApiService] 재시도 요청에서도 401 발생. 로그아웃 처리.");
            await logout();
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            if (!_isRefreshing) {
              _isRefreshing = true;
              _refreshCompleter = Completer<void>();
              final bool refreshed = await _refreshToken();
              _isRefreshing = false;
              _refreshCompleter?.complete();
              if (!refreshed) {
                await logout();
                return handler.next(error);
              }
            } else {
              await _refreshCompleter?.future;
            }

            String? newToken = await _storage.read(key: 'access_token');
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            options.extra['is_retry'] = true;

            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      String? refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // 🚀 AWS 주소로 변경
      final refreshDio = Dio(BaseOptions(baseUrl: "http://52.204.62.127:8080"));
      final response = await refreshDio.post(
        "/api/auth/refresh",
        data: refreshToken,
        options: Options(contentType: Headers.textPlainContentType),
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
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_role');
  }

  FlutterSecureStorage getStorage() => _storage;
  static Dio getDio() => ApiService().dio;
}
