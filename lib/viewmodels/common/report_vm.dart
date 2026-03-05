import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/common/api_service.dart';
import '../../models/common/report_model.dart';

class ReportState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? errorMessage;

  ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReportState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportViewModel extends StateNotifier<ReportState> {
  ReportViewModel() : super(ReportState());
  final _api = ApiService();

  // 1. 내 신고 내역 조회
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

  // 2. 새로운 신고 등록
  Future<bool> createReport(String reportedUserId, String reason, String content) async {
    try {
      await _api.dio.post("/api/reports", data: {
        "reportedUserId": reportedUserId,
        "reason": reason,
        "content": content,
      });
      await fetchReports(); // 등록 후 목록 새로고침
      return true;
    } catch (e) {
      return false;
    }
  }
}

final reportViewModelProvider = StateNotifierProvider<ReportViewModel, ReportState>((ref) {
  return ReportViewModel();
});
