// lib/viewmodels/auth/login_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;

  LoginState({this.isLoading = false, this.errorMessage});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel() : super(LoginState());

  final _storage = const FlutterSecureStorage();

  Future<String?> login(String id, String pw) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": id, "userPw": pw}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("서버 응답 데이터: ${response.body}");

        // 🔒 저장소 에러가 나더라도 여기서 멈추지 않게 개별 try-catch 사용
        try {
          await _storage.write(key: 'access_token', value: data['accessToken']);
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);

          final String role = data['role']?.toString() ?? "";
          await _storage.write(key: 'user_role', value: role);

          // 🚀 성공 시 로딩 해제 필수!
          state = state.copyWith(isLoading: false);
          return role;
        } catch (storageError) {
          print("저장소(SecureStorage) 에러: $storageError");
          // 저장 실패해도 일단 role은 반환해서 로그인은 되게 함
          state = state.copyWith(isLoading: false);
          return data['role']?.toString() ?? "";
        }
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "아이디 또는 비밀번호를 확인해주세요.");
        return null;
      }
    } catch (e) {
      print("로그인 통신 에러: $e");
      state = state.copyWith(isLoading: false, errorMessage: "서버 연결에 실패했습니다.");
      return null;
    }
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) => LoginViewModel());