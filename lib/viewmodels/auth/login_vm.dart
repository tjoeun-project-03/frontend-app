import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final String? userRole;

  LoginState({this.isLoading = false, this.errorMessage, this.userRole});

  LoginState copyWith({bool? isLoading, String? errorMessage, String? userRole}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userRole: userRole ?? this.userRole,
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
        final String role = data['role']?.toString() ?? "";

        final storage = _api.getStorage();
        await storage.write(key: 'access_token', value: data['accessToken']);
        await storage.write(key: 'refresh_token', value: data['refreshToken']);
        await storage.write(key: 'user_role', value: role);

        state = state.copyWith(isLoading: false, userRole: role);
        return role;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "아이디 또는 비밀번호를 확인해주세요.");
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "서버 연결에 실패했습니다.");
      return null;
    }
  }

  // 🚀 로그아웃 기능 추가
  Future<void> logout() async {
    try {
      final storage = _api.getStorage();
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      await storage.delete(key: 'user_role');
      
      // 🔒 상태 초기화
      state = LoginState();
    } catch (e) {
      print("로그아웃 처리 중 에러: $e");
    }
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) => LoginViewModel());
