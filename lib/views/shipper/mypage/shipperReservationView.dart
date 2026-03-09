import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/shipper/reservation_vm.dart';
import '../../../widgets/common/bottomNavBar.dart';

class ShipperReservationView extends ConsumerStatefulWidget {
  const ShipperReservationView({super.key});

  @override
  ConsumerState<ShipperReservationView> createState() => _ShipperReservationViewState();
}

class _ShipperReservationViewState extends ConsumerState<ShipperReservationView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      ref.read(reservationViewModelProvider.notifier).fetchReservations()
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color bgGrey = Color(0xFFF8F9FA);
    
    final reservationState = ref.watch(reservationViewModelProvider);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "이용 내역",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: reservationState.isLoading
          ? const Center(child: CircularProgressIndicator(color: jimlineNavy))
          : reservationState.reservations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: jimlineNavy,
                  onRefresh: () => ref.read(reservationViewModelProvider.notifier).fetchReservations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: reservationState.reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservationState.reservations[index];
                      return _buildReservationCard(context, reservation);
                    },
                  ),
                ),
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pop();
          } else {
            context.go('/shipper-home');
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "등록된 예약 내역이 없습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, dynamic reservation) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 상태 및 예약일
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: jimlineNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reservation.status, // 서버에서 오는 상태 그대로 표시
                  style: const TextStyle(color: jimlineNavy, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                reservation.formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 경로 표시 (출발 -> 도착)
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: jimlineNavy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reservation.departure,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 4),
            height: 20,
            width: 2,
            color: Colors.grey[200],
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reservation.arrival,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 상세 정보 (짐 종류 | 차량 | 무게)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildInfoItem("품목", reservation.content),
                _buildDivider(),
                _buildInfoItem("차량", reservation.carType),
                _buildDivider(),
                _buildInfoItem("무게", "${reservation.weight.toStringAsFixed(1)}t"),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 하단: 가격 및 송장 번호
          Row(
            children: [
              Text(
                "송장: ${reservation.invoiceNo}",
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              const Spacer(),
              Text(
                reservation.formattedPrice,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF222222)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF444444)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, color: Colors.grey[300]);
  }
}
