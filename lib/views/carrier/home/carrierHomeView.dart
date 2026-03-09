import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'orderBoardView.dart';
import '../mypage/carrierMyPageView.dart';
import '../../../viewmodels/carrier/carrier_tracking_vm.dart';

class CarrierHomeView extends ConsumerStatefulWidget {
  const CarrierHomeView({super.key});
  @override
  ConsumerState<CarrierHomeView> createState() => _CarrierHomeViewState();
}

class _CarrierHomeViewState extends ConsumerState<CarrierHomeView> {
  int _selectedIndex = 0;
  final Color primaryNavy = const Color(0xFF1A2B88);

  List<Widget> get _screens => [
    const OrderBoardView(),
    _buildDeliveryTab(),
    const Center(child: Text("정산 내역")),
    const CarrierMyPageView(),
  ];

  Widget _buildDeliveryTab() {
    final isTracking = ref.watch(carrierTrackingProvider);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isTracking ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping,
                size: 80,
                color: isTracking ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isTracking ? "실시간 위치 공유 중" : "운행 대기 중",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isTracking ? Colors.green : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "운행 시작 버튼을 누르면 화주에게\n내 위치가 실시간으로 전달됩니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (isTracking) {
                    ref.read(carrierTrackingProvider.notifier).stopTracking();
                  } else {
                    ref.read(carrierTrackingProvider.notifier).startTracking(62);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? Colors.red : primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isTracking ? "운행 종료 (위치 공유 중지)" : "운행 시작 (위치 공유)",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        children: _screens,
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
