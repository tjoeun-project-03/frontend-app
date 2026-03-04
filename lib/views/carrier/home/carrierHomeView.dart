// lib/views/carrier/home/carrierHomeView.dart
import 'package:flutter/material.dart';
import 'orderBoardView.dart';
import '../mypage/carrierMyPageView.dart';

class CarrierHomeView extends StatefulWidget {
  const CarrierHomeView({super.key});
  @override
  State<CarrierHomeView> createState() => _CarrierHomeViewState();
}

class _CarrierHomeViewState extends State<CarrierHomeView> {
  int _selectedIndex = 0;
  final Color primaryNavy = const Color(0xFF1A2B88);

  final List<Widget> _screens = [
    const OrderBoardView(), // 🚀 오더보드 탭
    const Center(child: Text("내 운송")),
    const Center(child: Text("정산 내역")),
    const CarrierMyPageView(),
  ];

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
      body: IndexedStack( // 🚀 탭 전환 시 상태를 유지하기 위해 IndexedStack 사용
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