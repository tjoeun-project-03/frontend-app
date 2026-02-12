import 'package:flutter/material.dart';
import 'shipperHomeView.dart';
import 'shipperMyView.dart';
import '../../widgets/common/bottomNavBar.dart';

class ShopperNavController extends StatefulWidget {
  const ShopperNavController({super.key});

  @override
  State<ShopperNavController> createState() => _ShopperNavControllerState();
}

class _ShopperNavControllerState extends State<ShopperNavController> {
  int _selectedIndex = 0;

  // 네비게이션으로 전환할 화면들
  final List<Widget> _pages = [
    const ShipperHomeView(), // 홈 (운송 예약)
    const Center(child: Text("운송 현황")),
    const Center(child: Text("기록")),
    const ShipperMyView(),   // 마이페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack을 쓰면 페이지 이동 시에도 입력 중이던 데이터가 유지됩니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 디자인 위젯 연결
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}