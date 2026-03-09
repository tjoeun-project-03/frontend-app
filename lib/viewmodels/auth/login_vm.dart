import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final String? userRole; // 🚀 역할(Role) 필드 추가

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

        // 🔒 저장소에 토큰 저장
        final storage = _api.getStorage();
        await storage.write(key: 'access_token', value: data['accessToken']);
        await storage.write(key: 'refresh_token', value: data['refreshToken']);
        await storage.write(key: 'user_role', value: role);

        // 🚀 상태에 역할 저장
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
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) => LoginViewModel());
