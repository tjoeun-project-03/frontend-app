// lib/viewmodels/auth/login_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

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

  final _api = ApiService();

  Future<String?> login(String id, String pw) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.dio.post(
        "/api/auth/login",
        data: {"userId": id, "userPw": pw},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("서버 응답 데이터: ${response.data}");

        // 🔒 저장소에 토큰 저장
        try {
          final storage = _api.getStorage();
          await storage.write(key: 'access_token', value: data['accessToken']);
          await storage.write(key: 'refresh_token', value: data['refreshToken']);
          final String role = data['role']?.toString() ?? "";
          await storage.write(key: 'user_role', value: role);

          state = state.copyWith(isLoading: false);
          return role;
        } catch (storageError) {
          print("저장소 에러: $storageError");
          state = state.copyWith(isLoading: false);
          return data['role']?.toString() ?? "";
        }
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "아이디 또는 비밀번호를 확인해주세요.");
        return null;
      }
    } catch (e) {
      print("로그인 에러: $e");
      state = state.copyWith(isLoading: false, errorMessage: "서버 연결에 실패했습니다.");
      return null;
    }
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) => LoginViewModel());