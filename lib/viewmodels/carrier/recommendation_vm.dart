import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/common/api_service.dart';
import '../../models/carrier/recommendation_model.dart';

class RecommendationState {
  final List<RecommendedOrder> recommendations;
  final bool isLoading;
  final String? error;

  RecommendationState({this.recommendations = const [], this.isLoading = false, this.error});

  RecommendationState copyWith({List<RecommendedOrder>? recommendations, bool? isLoading, String? error}) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecommendationViewModel extends StateNotifier<RecommendationState> {
  RecommendationViewModel() : super(RecommendationState());

  final _api = ApiService();

  Future<void> fetchBackHomeTop3({
    required double currentLat,
    required double currentLng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final meRes = await _api.dio.get("/api/users/me");
      final carrierRes = await _api.dio.get("/api/users/me/carrier");

      final String homeAddress = meRes.data['address'] ?? "";
      final String rawCarType = carrierRes.data['carType'] ?? "TON_1";

      String mappedCarType = "1t";
      if (rawCarType.contains("1_4")) mappedCarType = "1.4t";
      else if (rawCarType.contains("2_5")) mappedCarType = "2.5t";
      else if (rawCarType.contains("5")) mappedCarType = "5t";
      else mappedCarType = "1t";

      final geoRes = await Dio().get(
        "https://apis.openapi.sk.com/tmap/geo/fullAddrGeo",
        queryParameters: {
          "version": 1,
          "fullAddr": homeAddress,
          "appKey": "zevdfBBPeu3eQZItbMK1k812led3px8x2dr5r9sZ",
        },
      );

      double homeLat = 37.5665;
      double homeLng = 126.9780;

      if (geoRes.statusCode == 200) {
        final coordinate = geoRes.data['coordinateInfo']['coordinate'][0];
        homeLat = double.parse(coordinate['newLat'] ?? coordinate['lat']);
        homeLng = double.parse(coordinate['newLon'] ?? coordinate['lon']);
      }

      final requestBody = {
        "current_lat": currentLat,
        "current_lng": currentLng,
        "home_lat": homeLat,
        "home_lng": homeLng,
        "car_type": mappedCarType,
      };

      // 🚀 AWS 주소로 변경
      final response = await Dio().post(
        "http://52.204.62.127:8000/api/v1/recommendations/top3",
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        if (data.isEmpty) {
          state = state.copyWith(isLoading: false, error: "조건에 맞는 추천 오더가 없습니다.");
        } else {
          final list = data.map((json) => RecommendedOrder.fromJson(json)).toList();
          state = state.copyWith(recommendations: list, isLoading: false);
        }
      }
    } catch (e) {
      print("❌ [AI 추천 에러] $e");
      state = state.copyWith(isLoading: false, error: "추천 데이터를 가져오는데 실패했습니다.");
    }
  }
}

final recommendationProvider = StateNotifierProvider<RecommendationViewModel, RecommendationState>((ref) {
  return RecommendationViewModel();
});
