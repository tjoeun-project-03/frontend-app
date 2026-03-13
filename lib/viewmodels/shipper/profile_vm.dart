import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';
import 'package:http/http.dart' as http;

import '../../models/shipper/shipment_summary.dart';

class ProfileState {
  final String userName;
  final String email;
  final bool isLoading;
  final ShipmentSummary? summary;

  ProfileState({
    this.userName = "",
    this.email = "",
    this.isLoading = false,
    this.summary,
  });

  ProfileState copyWith({String? userName, String? email, bool? isLoading, ShipmentSummary? summary}) {
    return ProfileState(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
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
      final results = await Future.wait([
        _api.dio.get("/api/users/me"),
        _api.dio.get("/api/orders/summary")
      ]);

      final profileData = results[0].data;
      final summaryData = ShipmentSummary.fromJson(results[1].data);

      state = state.copyWith(
        userName: profileData['userName'],
        email: profileData['email'],
        summary: summaryData,
        isLoading: false,
      );

    } catch (e) {
      print("프로필 조회 에러: $e");
      state = state.copyWith(isLoading: false, userName: "연결 오류");
    }
  }

  Future<bool> logout() async {
    try {
      // 🚀 AWS 주소로 변경
      final url = Uri.parse("http://52.204.62.127:8080/api/auth/logout");

      final response = await http.post(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("✅ 서버 로그아웃 응답 성공");
      }
    } catch (e) {
      print("⚠️ 서버 로그아웃 통신 건너뜀: $e");
    } finally {
      await _api.logout();
    }
    return true;
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) => ProfileViewModel());
