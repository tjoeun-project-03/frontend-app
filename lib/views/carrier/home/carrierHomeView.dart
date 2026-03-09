import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'orderBoardView.dart';
import 'carrierTrackingView.dart';
import '../mypage/carrierMyPageView.dart';
import '../../../viewmodels/carrier/active_order_vm.dart';

class CarrierHomeView extends ConsumerStatefulWidget {
  const CarrierHomeView({super.key});
  @override
  ConsumerState<CarrierHomeView> createState() => _CarrierHomeViewState();
}

class _CarrierHomeViewState extends ConsumerState<CarrierHomeView> {
  int _selectedIndex = 0;
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeOrderProvider.notifier).syncWithServer());
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeOrderProvider);
    
    if (!activeState.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1A2B88))),
      );
    }

    if (activeState.activeOrder != null) {
      return const CarrierTrackingView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ["오더 보드", "내 운송", "정산 내역", "마이 페이지"][_selectedIndex],
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
        // 🚀 오더보드 탭일 때만 우측 상단에 복귀 추천 버튼 노출
        actions: _selectedIndex == 0 ? [
          TextButton.icon(
            onPressed: _navigateToRecommendation,
            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.amber),
            label: Text("복귀 추천", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ] : null,
      ),
      body: IndexedStack(index: _selectedIndex, children: [
        const OrderBoardView(),
        const Center(child: Text("내 운송")),
        const Center(child: Text("정산 내역")),
        const CarrierMyPageView(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "오더보드"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: "내 운송"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "정산내역"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "마이페이지"),
        ],
      ),
    );
  }

  // 🚀 현재 위치를 기반으로 추천 페이지 이동
  Future<void> _navigateToRecommendation() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        context.push('/carrier-recommendation', extra: {'lat': position.latitude, 'lng': position.longitude});
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("위치 정보를 가져올 수 없습니다.")));
      }
    }
  }
}
