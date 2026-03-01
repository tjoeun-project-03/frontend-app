import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

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
      await _api.dio.post("/api/auth/logout");
    } catch (e) {
      print("로그아웃 에러: $e");
    } finally {
      await _api.logout();
    }
    return true;
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) => ProfileViewModel());