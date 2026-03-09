import 'package:flutter/material.dart';
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

  CarrierProfileState copyWith({
    String? userName,
    String? car,
    String? carType,
    String? carNum,
    double? rating,
    int? reviewCount,
    bool? isLoading,
    int? totalIncome,
    int? totalOrders,
    double? completionRate,
    int? avgTime,
    double? totalDistance,
    List<OrderResponse>? allOrders,
  }) {
    return CarrierProfileState(
      userName: userName ?? this.userName,
      car: car ?? this.car,
      carType: carType ?? this.carType,
      carNum: carNum ?? this.carNum,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLoading: isLoading ?? this.isLoading,
      totalIncome: totalIncome ?? this.totalIncome,
      totalOrders: totalOrders ?? this.totalOrders,
      completionRate: completionRate ?? this.completionRate,
      avgTime: avgTime ?? this.avgTime,
      totalDistance: totalDistance ?? this.totalDistance,
      allOrders: allOrders ?? this.allOrders,
    );
  }
}

class CarrierProfileViewModel extends StateNotifier<CarrierProfileState> {
  CarrierProfileViewModel() : super(CarrierProfileState());
  final _api = ApiService();

  Future<void> fetchProfile() async {
    try {
      state = state.copyWith(isLoading: true);

      final results = await Future.wait([
        _api.dio.get("/api/users/me"),
        _api.dio.get("/api/users/me/carrier"),
        _api.dio.get("/api/orders/my"), 
      ]);

      final userData = results[0].data;
      final carrierData = results[1].data;
      final List<dynamic> ordersData = results[2].data;

      // JSON -> OrderResponse 모델 변환
      final List<OrderResponse> orders = ordersData.map((e) => OrderResponse.fromJson(e)).toList();

      int incomeSum = 0;
      double distanceSum = 0;
      int completedCount = 0;
      int totalDuration = 0;

      for (var order in orders) {
        // 메모: 상태값이 '배송 완료' 또는 'COMPLETED'인 경우를 체크합니다.
        final String status = order.status.trim().toUpperCase();
        final bool isCompleted = status == '배송 완료' || status == 'COMPLETED';

        if (isCompleted) {
          incomeSum += order.price;
          distanceSum += order.distance;
          completedCount++;
          totalDuration += order.duration;
        }
      }

      // 메모: 전체 오더 수 대비 완료된 오더 수의 비율을 계산합니다. (요청 사항 반영)
      double totalCompletionRate = orders.isNotEmpty 
          ? (completedCount / orders.length) * 100 
          : 0.0;
      
      int avgDur = completedCount > 0 ? (totalDuration ~/ completedCount) : 0;

      state = state.copyWith(
        userName: userData['userName'] ?? "이름 없음",
        car: carrierData['car'] ?? "차량 정보 없음",
        carType: carrierData['carType'] ?? "",
        carNum: carrierData['carNum'] ?? "",
        rating: (carrierData['averageRating'] ?? 0.0).toDouble(),
        reviewCount: carrierData['reviewCount'] ?? 0,
        totalIncome: incomeSum,
        totalOrders: completedCount,
        completionRate: totalCompletionRate,
        avgTime: avgDur,
        totalDistance: distanceSum,
        allOrders: orders,
        isLoading: false,
      );
      print("메모: 통계 계산 완료 - 전체:${orders.length}, 완료:$completedCount, 비율:${totalCompletionRate.toStringAsFixed(1)}%");

    } catch (e) {
      print("메모: 프로필 및 통계 조회 최종 실패 - $e");
      state = state.copyWith(isLoading: false);
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
