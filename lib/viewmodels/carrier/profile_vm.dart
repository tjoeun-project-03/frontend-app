import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';
import '../../models/carrier/order_model.dart';

class CarrierProfileState {
  final String userName;    
  final String car;         
  final String carType;
  final String carNum;
  final double rating;
  final int reviewCount;
  final bool isLoading;
  final int totalIncome;      
  final int totalOrders;      
  final double completionRate; 
  final int avgTime;          
  final double totalDistance; 
  final List<OrderResponse> allOrders;

  CarrierProfileState({
    this.userName = "",
    this.car = "",
    this.carType = "",
    this.carNum = "",
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isLoading = true,
    this.totalIncome = 0,
    this.totalOrders = 0,
    this.completionRate = 0.0,
    this.avgTime = 0,
    this.totalDistance = 0.0,
    this.allOrders = const [],
  });
}

class CarrierProfileViewModel extends StateNotifier<CarrierProfileState> {
  CarrierProfileViewModel() : super(CarrierProfileState());
  final _api = ApiService();

  Future<void> fetchProfile() async {
    try {
      final results = await Future.wait([
        _api.dio.get("/api/users/me"),
        _api.dio.get("/api/users/me/carrier"),
        _api.dio.get("/api/orders/my"), 
      ]);

      final userData = results[0].data;
      final carrierData = results[1].data;
      final List<dynamic> ordersData = results[2].data;

      // JSON -> OrderResponse 변환
      final List<OrderResponse> orders = ordersData.map((e) => OrderResponse.fromJson(e)).toList();

      int incomeSum = 0;
      double distanceSum = 0;
      int completedCount = 0;
      int totalDuration = 0;
      
      final now = DateTime.now();
      int thisMonthTotal = 0;
      int thisMonthCompleted = 0;

      for (var order in orders) {
        if (order.status == 'COMPLETED') {
          incomeSum += order.price;
          distanceSum += order.distance;
          completedCount++;
          totalDuration += order.duration;
        }

        if (order.created.isNotEmpty) {
          try {
            final createdAt = DateTime.parse(order.created);
            if (createdAt.year == now.year && createdAt.month == now.month) {
              thisMonthTotal++;
              if (order.status == 'COMPLETED') thisMonthCompleted++;
            }
          } catch (_) {}
        }
      }

      double monthRate = thisMonthTotal > 0 
          ? (thisMonthCompleted / thisMonthTotal) * 100 
          : 0.0;
      
      int avgDur = completedCount > 0 ? (totalDuration ~/ completedCount) : 0;

      state = CarrierProfileState(
        userName: userData['userName'] ?? "이름 없음",
        car: carrierData['car'] ?? "차량 정보 없음",
        carType: carrierData['carType'] ?? "",
        carNum: carrierData['carNum'] ?? "",
        rating: (carrierData['averageRating'] ?? 0.0).toDouble(),
        reviewCount: carrierData['reviewCount'] ?? 0,
        totalIncome: incomeSum,
        totalOrders: completedCount,
        completionRate: monthRate,
        avgTime: avgDur,
        totalDistance: distanceSum,
        allOrders: orders, // 리스트 저장
        isLoading: false,
      );
    } catch (e) {
      print("프로필 및 통계 조회 실패: $e");
      state = CarrierProfileState(isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post("/api/auth/logout");
    } catch (e) {
      print("서버 로그아웃 요청 실패: $e");
    } finally {
      await _api.logout();
      state = CarrierProfileState(isLoading: false);
    }
  }
}

final carrierProfileProvider = StateNotifierProvider<CarrierProfileViewModel, CarrierProfileState>((ref) => CarrierProfileViewModel());
