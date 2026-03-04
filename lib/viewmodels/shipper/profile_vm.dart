import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';
import 'package:http/http.dart' as http;

class ProfileState {
  final String userName;
  final String email;
  final bool isLoading;

  ProfileState({
    this.userName = "",
    this.email = "",
    this.isLoading = false,
  });

  ProfileState copyWith({String? userName, String? email, bool? isLoading}) {
    return ProfileState(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel() : super(ProfileState()) {
    fetchProfile();
  }

  final _api = ApiService();

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.dio.get("/api/users/me");

      if (response.statusCode == 200) {
        final data = response.data;
        state = state.copyWith(
          userName: data['userName'],
          email: data['email'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, userName: "정보 불러오기 실패");
      }
    } catch (e) {
      print("프로필 조회 에러: $e");
      state = state.copyWith(isLoading: false, userName: "연결 오류");
    }
  }

  Future<bool> logout() async {
    try {
      // 1. 순수 http 패키지로 인증 헤더 없이 깔끔하게 요청
      // URL은 본인의 설정(10.0.2.2 등)에 맞게 수정하세요.
      final url = Uri.parse("http://10.0.2.2:8080/api/auth/logout");

      final response = await http.post(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("✅ 서버 로그아웃 응답 성공");
      }
    } catch (e) {
      // 네트워크 오류나 타임아웃이 나더라도 로그아웃 프로세스는 계속 진행
      print("⚠️ 서버 로그아웃 통신 건너뜀: $e");
    } finally {
      // 2. 가장 중요한 로컬 데이터(SharedPrefs, SecureStorage 등) 삭제
      // 이 작업이 완료되어야 다음 앱 실행 시 로그인 화면이 뜹니다.
      await _api.logout();
    }
    return true;
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) => ProfileViewModel());