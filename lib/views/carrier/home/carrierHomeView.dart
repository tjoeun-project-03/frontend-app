// views/carrier/carrierHomeView.dart
import 'package:flutter/material.dart';
import '../mypage/carrierMyPageView.dart';

class CarrierHomeView extends StatefulWidget {
  const CarrierHomeView({super.key});

  @override
  State<CarrierHomeView> createState() => _CarrierHomeViewState();
}

class _CarrierHomeViewState extends State<CarrierHomeView> {
  int _selectedIndex = 0;
  final Color primaryNavy = const Color(0xFF1A2B88);

  // 🚀 탭별 타이틀 리스트 추가
  final List<String> _titles = ["오더 보드", "내 운송", "정산 내역", "마이 페이지"];

  // 탭별 화면 리스트
  final List<Widget> _screens = [
    const OrderBoardContent(), // 첫 번째 탭: 오더 보드
    const Center(child: Text("내 운송")),
    const Center(child: Text("정산 내역")),
    const CarrierMyPageView(), // 네 번째 탭: 마이페이지 (Scaffold 제거 버전)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 🚀 현재 선택된 인덱스에 따라 타이틀이 바뀝니다.
        title: Text(
            _titles[_selectedIndex],
            style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)
        ),
        actions: [
          // 오더보드일 때만 알림 아이콘 표시
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "오더보드"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: "내 운송"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "정산내역"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "마이페이지"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryNavy,
        child: const Icon(Icons.refresh, color: Colors.white),
      )
          : null,
    );
  }
}

// 오더보드 내부 컨텐츠 위젯 (기존과 동일)
class OrderBoardContent extends StatelessWidget {
  const OrderBoardContent({super.key});
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTopTab("전체 오더", true),
              const SizedBox(width: 8),
              _buildTopTab("내입찰", false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              _buildFilterChip("필터", isFirst: true),
              _buildFilterChip("거리순"),
              _buildFilterChip("차량 종류"),
              _buildFilterChip("상하차방식"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPremiumCard(),
              const SizedBox(height: 12),
              _buildNormalCard("경기 화성시", "충남 천안시", "1톤 탑차", "45km", "65,000원", "내일 오전 08:00 상차", "24분 전 등록"),
              _buildNormalCard("인천 중구", "경북 칠곡군", "11톤윙바디", "210km", "320,000원", "오늘 오후 14:00 상차 (팔레트)", "내위치에서 12km"),
              _buildNormalCard("전남 광양시", "강원 동해시", "25톤트레일러", "420km", "550,000원", "내일 오전 06:00 상차", "1시간 전 등록"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopTab(String label, bool isActive) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? primaryNavy : Colors.grey[300]!, width: 1.5),
      ),
      child: Center(child: Text(label, style: TextStyle(color: isActive ? primaryNavy : Colors.grey, fontWeight: FontWeight.bold))),
    ),
  );

  Widget _buildFilterChip(String label, {bool isFirst = false}) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: isFirst ? primaryNavy : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isFirst ? primaryNavy : Colors.grey[300]!),
    ),
    child: Row(children: [
      Text(label, style: TextStyle(color: isFirst ? Colors.white : Colors.black, fontSize: 13)),
      if (!isFirst) const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
    ]),
  );

  Widget _buildPremiumCard() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primaryNavy.withOpacity(0.3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: primaryNavy,
          alignment: Alignment.centerRight,
          child: const Text("PREMIUM SURCHARGE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              Container(width: 80, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200])),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("⚡ 긴급 할증+20%", style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("서울 강남구 → 부산 강서구", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("5톤 카고 | 380km | 당일착", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
            ]),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("ESTIMATED FEE", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text("480,000원", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("선택하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ),
      ]),
    ),
  );

  Widget _buildNormalCard(String start, String end, String car, String dist, String price, String time, String reg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("$car  $dist", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 8),
      Text("$start ➔ $end", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy)),
      const SizedBox(height: 4),
      Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(reg, style: const TextStyle(color: Colors.grey, fontSize: 11))]),
        const Text("상세보기", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)),
      ]),
    ]),
  );
}