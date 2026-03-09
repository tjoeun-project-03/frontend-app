import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // 🚀 앱이 켜질 때 서버와 상태 동기화 수행
    Future.microtask(() => ref.read(activeOrderProvider.notifier).syncWithServer());
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeOrderProvider);
    
    // 1. 서버 확인이 끝나기 전까지는 로딩 화면 고정 (오더보드 진입 원천 차단)
    if (!activeState.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1A2B88)),
              SizedBox(height: 24),
              Text("운송 현황 동기화 중...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // 2. [핵심 로직] 진행 중인 배차가 있다면 트래킹(지도) 화면으로 고정
    if (activeState.activeOrder != null) {
      return const CarrierTrackingView();
    }

    // 3. 진행 중인 배차가 없을 때만 일반 탭 UI 노출
    final List<Widget> screens = [
      const OrderBoardView(),
      const Center(child: Text("내 운송")),
      const Center(child: Text("정산 내역")),
      const CarrierMyPageView(),
    ];

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
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
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
}
