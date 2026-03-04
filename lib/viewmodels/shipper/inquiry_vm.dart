import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shipper/inquiry_model.dart';
import '../../services/shipper/inquiry_service.dart';

class InquiryState {
  final List<InquiryModel> inquiries;
  final bool isLoading;
  final bool isSubmitting;

  InquiryState({
    this.inquiries = const [],
    this.isLoading = false,
    this.isSubmitting = false,
  });

  InquiryState copyWith({
    List<InquiryModel>? inquiries,
    bool? isLoading,
    bool? isSubmitting,
  }) {
    return InquiryState(
      inquiries: inquiries ?? this.inquiries,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class InquiryNotifier extends StateNotifier<InquiryState> {
  final InquiryService _service;

  InquiryNotifier(this._service) : super(InquiryState()) {
    fetchInquiries();
  }

  Future<void> fetchInquiries() async {
    state = state.copyWith(isLoading: true);
    try {
      final inquiries = await _service.getInquiries();
      inquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(inquiries: inquiries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 수정됨: category 파라미터 추가
  Future<bool> addInquiry(String title, String content, String category) async {
    state = state.copyWith(isSubmitting: true);
    final success = await _service.createInquiry(title, content, category);
    if (success) {
      await fetchInquiries();
    }
    state = state.copyWith(isSubmitting: false);
    return success;
  }
}

final inquiryServiceProvider = Provider((ref) => InquiryService());

final inquiryViewModelProvider = StateNotifierProvider<InquiryNotifier, InquiryState>((ref) {
  final service = ref.watch(inquiryServiceProvider);
  return InquiryNotifier(service);
});
