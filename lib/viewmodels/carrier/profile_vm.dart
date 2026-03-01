// lib/viewmodels/carrier/profile_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/common/api_service.dart';

class CarrierProfileState {
  final String userName;    // /api/users/me 에서 가져옴
  final String car;         // /api/users/me/carrier 에서 가져옴
  final String carType;
  final String carNum;
  final double rating;
  final int reviewCount;
  final bool isLoading;

  CarrierProfileState({
    this.userName = "",
    this.car = "",
    this.carType = "",
    this.carNum = "",
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isLoading = true,
  });
}

class CarrierProfileViewModel extends StateNotifier<CarrierProfileState> {
  CarrierProfileViewModel() : super(CarrierProfileState());
  final _api = ApiService();

  Future<void> fetchProfile() async {
    try {
      // 🚀 이름과 차량 정보를 각각의 API에서 동시에 가져옵니다.
      final results = await Future.wait([
        _api.dio.get("/api/users/me"),
        _api.dio.get("/api/users/me/carrier"),
      ]);

      final userData = results[0].data;
      final carrierData = results[1].data;

      state = CarrierProfileState(
        userName: userData['userName'] ?? "이름 없음",
        car: carrierData['car'] ?? "차량 정보 없음",
        carType: carrierData['carType'] ?? "",
        carNum: carrierData['carNum'] ?? "",
        rating: (carrierData['averageRating'] ?? 0.0).toDouble(),
        reviewCount: carrierData['reviewCount'] ?? 0,
        isLoading: false,
      );
    } catch (e) {
      print("프로필 통합 조회 실패: $e");
      state = CarrierProfileState(isLoading: false);
    }
  }

  // 🚀 서버 로그아웃 API 호출 및 로컬 세션 삭제
  Future<void> logout() async {
    try {
      // 서버에 로그아웃 알림 (AuthController.java의 /logout 호출)
      await _api.dio.post("/api/auth/logout"); //
    } catch (e) {
      print("서버 로그아웃 요청 실패: $e");
    } finally {
      // 서버 성공 여부와 상관없이 내 폰의 토큰은 반드시 삭제
      await _api.logout(); //
      state = CarrierProfileState(isLoading: false);
    }
  }
}

final carrierProfileProvider = StateNotifierProvider<CarrierProfileViewModel, CarrierProfileState>((ref) => CarrierProfileViewModel());