import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shipper/reservation_model.dart';
import '../../services/shipper/reservation_service.dart';

class ReservationState {
  final List<ReservationModel> reservations;
  final bool isLoading;

  ReservationState({
    this.reservations = const [],
    this.isLoading = false,
  });

  ReservationState copyWith({
    List<ReservationModel>? reservations,
    bool? isLoading,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final ReservationService _service;

  ReservationNotifier(this._service) : super(ReservationState()) {
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    state = state.copyWith(isLoading: true);
    try {
      final List<ReservationModel> reservations = await _service.getReservations();
      
      // 🚀 수정됨: id를 orderId로 변경하여 정렬 (최신순)
      reservations.sort((a, b) => b.orderId.compareTo(a.orderId));
      
      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      print("🚨 [ReservationNotifier] Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }
}

final reservationServiceProvider = Provider((ref) => ReservationService());

final reservationViewModelProvider = StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return ReservationNotifier(service);
});
