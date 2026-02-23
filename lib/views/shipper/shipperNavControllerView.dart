import 'package:flutter/material.dart';
import '../shipper/home/shipperHomeView.dart';
import '../shipper/mypage/shipperMyView.dart';
import '../shipper/tracking/shipperHistoryTrackingView.dart';
import '../../widgets/common/bottomNavBar.dart';

class ShipperNavController extends StatefulWidget {
  const ShipperNavController({super.key});

  @override
  State<ShipperNavController> createState() => _ShipperNavControllerState();
}

class _ShipperNavControllerState extends State<ShipperNavController> {
  int _selectedIndex = 0;

  // 원래 기획대로 3개의 타이틀 유지
  final List<String> _titles = ["운송 예약", "이용 내역 및 운송 추적", "마이페이지"];

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0: return const ShipperHomeView();
      case 1: return const ShipperHistoryTrackingView();
      case 2: return const ShipperMyView();
      default: return const ShipperHomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex],
            style: const TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _getSelectedPage(_selectedIndex),
      ),
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // 네비바의 인덱스가 3개를 넘어가지 않도록 안전장치
          if (index < _titles.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}