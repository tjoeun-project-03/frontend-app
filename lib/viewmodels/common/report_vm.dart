import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/common/api_service.dart';
import '../../models/common/report_model.dart';
import 'package:dio/dio.dart';

class ReportState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? errorMessage;
  final String reporterId;
  final String reportedUserId;

  ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
    this.reporterId = "",
    this.reportedUserId = "",
  });

  ReportState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? errorMessage,
    String? reporterId,
    String? reportedUserId,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      reporterId: reporterId ?? this.reporterId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
    );
  }
}

class ReportViewModel extends StateNotifier<ReportState> {
  ReportViewModel() : super(ReportState());
  final _api = ApiService();

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.dio.get("/api/reports/my");
      final List<dynamic> data = response.data;
      final reports = data.map((json) => ReportModel.fromJson(json)).toList();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 메모: 무한 로딩 방지를 위해 순차 로드 및 타임아웃 적용
  Future<void> loadReportInfo(int orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, reporterId: "", reportedUserId: "");
    print("메모: 신고 정보 로드 시작 - 오더 ID: $orderId");
    
    try {
      // 1. 내 정보 조회 (3초 타임아웃)
      final userRes = await _api.dio.get("/api/users/me").timeout(const Duration(seconds: 3));
      final String myId = (userRes.data['userId'] ?? userRes.data['id']).toString();
      print("메모: 내 정보 로드 성공 - ID: $myId");

      // 2. 오더 정보 조회 (3초 타임아웃)
      final orderRes = await _api.dio.get("/api/orders/id/$orderId").timeout(const Duration(seconds: 3));
      final orderData = orderRes.data;
      print("메모: 오더 정보 로드 성공");

      final String shipperId = (orderData['shipperId'] ?? "").toString();
      final String carrierId = (orderData['carrierId'] ?? "").toString();

      // 3. 상대방 판별
      String targetId = (myId == shipperId) ? carrierId : shipperId;

      state = state.copyWith(
        reporterId: myId,
        reportedUserId: targetId,
        isLoading: false,
      );
    } catch (e) {
      print("메모: 정보 로드 중 오류 발생 - $e");
      state = state.copyWith(
        isLoading: false, 
        errorMessage: "오더 정보를 가져오지 못했습니다. 번호를 다시 확인해주세요.",
      );
    }
  }

  Future<bool> createReport({
    required int orderId,
    required String reason,
    required String content,
  }) async {
    try {
      if (state.reportedUserId.isEmpty) return false;

      await _api.dio.post("/api/reports", data: {
        "orderId": orderId,
        "reportedUserId": state.reportedUserId,
        "reason": reason,
        "content": content,
      });

      await fetchReports();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final reportViewModelProvider = StateNotifierProvider<ReportViewModel, ReportState>((ref) => ReportViewModel());
