import 'package:flutter/material.dart';
import '../../widgets/common/bottomNavBar.dart';

class ShipperHomeView extends StatefulWidget {
  const ShipperHomeView({super.key});

  @override
  State<ShipperHomeView> createState() => _ShipperHomeViewState();
}

class _ShipperHomeViewState extends State<ShipperHomeView> {
  int _currentIndex = 0;
  double _estimatedWeight = 1.0; // 예상 무게 초기값
  String? _selectedCategory; // 선택된 화물 카테고리

  // 화물 정보 데이터를 아이콘과 함께 정의
  final List<Map<String, dynamic>> _categories = [
    {"name": "박스/잡화", "icon": Icons.inventory_2_outlined},
    {"name": "가구", "icon": Icons.chair_outlined},
    {"name": "가전", "icon": Icons.tv_outlined},
    {"name": "냉장/냉동", "icon": Icons.snowing},
    {"name": "기타", "icon": Icons.more_horiz_outlined},
  ];

  final Color jimlineNavy = const Color(0xFF1A2B88);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("운송 예약", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.notifications_none, color: jimlineNavy), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 출발지/도착지 검색 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _buildSearchField(Icons.search, Colors.blue, "출발지 검색"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    _buildSearchField(Icons.place, Colors.red, "도착지 검색"),
                  ],
                ),
              ),
            ),

            // 2. 지도 영역
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text("지도 API 영역", style: TextStyle(color: Colors.grey))),
            ),

            const SizedBox(height: 24),

            // 3. 화물 정보 카테고리 선택
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("화물 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: jimlineNavy)),
            ),
            const SizedBox(height: 12),
            _buildCategoryList(), // 분리된 카테고리 리스트 호출

            const SizedBox(height: 32),

            // 4. 예상 무게 조절 (슬라이더)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("예상 무게", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: jimlineNavy)),
                  Text("${_estimatedWeight.toStringAsFixed(1)} 톤", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jimlineNavy)),
                ],
              ),
            ),
            Slider(
              value: _estimatedWeight,
              min: 0.5,
              max: 25.0,
              divisions: 49,
              activeColor: jimlineNavy,
              inactiveColor: Colors.grey[200],
              onChanged: (value) => setState(() => _estimatedWeight = value),
            ),

            const SizedBox(height: 40),

            // 5. 예약 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: jimlineNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("운송 예약하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      // 분리된 하단 네비게이션 바 적용
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // 카테고리 리스트
  Widget _buildCategoryList() {
    return SizedBox(
      height: 100, // 카드 높이 설정
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index]["name"];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]["name"]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 85,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? jimlineNavy : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? jimlineNavy : Colors.grey[200]!,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: jimlineNavy.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categories[index]["icon"],
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index]["name"],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(IconData icon, Color color, String hint) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}