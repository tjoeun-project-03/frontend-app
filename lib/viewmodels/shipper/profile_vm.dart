import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileState {
  final String userName;
  final String email;
  final bool isLoading;

  ProfileState({
    this.userName = "불러오는 중...",
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
    fetchProfile(); // 뷰모델 생성 시 자동으로 프로필 로드
  }

  final _storage = const FlutterSecureStorage();

  // 1. 서버에서 내 프로필 정보 가져오기
  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'access_token');

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/users/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8.decode 사용
        final data = jsonDecode(utf8.decode(response.bodyBytes));
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

  // 2. 로그아웃 처리
  Future<bool> logout() async {
    final token = await _storage.read(key: 'access_token');
    try {
      // 서버 로그아웃 API 호출
      await http.post(
        Uri.parse("http://10.0.2.2:8080/api/auth/logout"),
        headers: {"Authorization": "Bearer $token"},
      );
    } catch (e) {
      print("로그아웃 통신 에러: $e");
    } finally {
      // 서버 성공 여부와 관계없이 로컬 토큰 삭제
      await _storage.deleteAll();
    }
    return true;
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) => ProfileViewModel());