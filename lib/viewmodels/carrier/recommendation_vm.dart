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
      final results = await Future.wait([
        _api.dio.get("/api/users/me"),
        _api.dio.get("/api/users/me/carrier")
      ]);

      final String homeAddress = results[0].data['address'] ?? "";
      final String rawCarType = results[1].data['carType'] ?? "TON_1";

      // 🚀 AI 서버(Python)의 CSV 데이터 형식에 맞게 차종 명칭 변환
      // DB: TON_1 -> CSV: 1t
      String mappedCarType = "1t";
      if (rawCarType.contains("1_4")) mappedCarType = "1.4t";
      else if (rawCarType.contains("2_5")) mappedCarType = "2.5t";
      else if (rawCarType.contains("5")) mappedCarType = "5t";
      else mappedCarType = "1t";

      // 1. 주소 -> 좌표 변환
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
        "car_type": mappedCarType, // 🚀 변환된 차종 전달
      };

      print("📡 [AI Request] 데이터 송신: $requestBody");

      // 2. AI 서버 호출
      final response = await Dio().post(
        "http://10.0.2.2:8000/api/v1/recommendations/top3",
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print("🔍 [AI Response] 수신된 추천 수: ${data.length}");
        
        if (data.isEmpty) {
          state = state.copyWith(isLoading: false, error: "현재 위치(${currentLat.toStringAsFixed(2)})에서 집 방향으로 가는 적절한 오더를 찾지 못했습니다.");
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
