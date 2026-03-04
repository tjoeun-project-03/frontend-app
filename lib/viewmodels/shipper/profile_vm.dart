import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

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
        _api.dio.get("/api/orders/summary") // 새 API
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