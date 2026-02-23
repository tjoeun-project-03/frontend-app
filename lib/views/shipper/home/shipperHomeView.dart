import 'package:flutter/material.dart';
import 'shipperPaymentView.dart';

class ShipperHomeView extends StatefulWidget {
  const ShipperHomeView({super.key});

  @override
  State<ShipperHomeView> createState() => _ShipperHomeViewState();
}

class _ShipperHomeViewState extends State<ShipperHomeView> {
  double _estimatedWeight = 1.0;
  String? _selectedCategory;

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
    // 무게에 따른 가상 가격 계산 로직 (예시 : 톤당 5만원 + 기본료 3만원)
    int estimatedPrice = (_estimatedWeight * 50000 + 30000).toInt();

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          // 이 부분을 추가하면 스크롤 영역이 명확해집니다.
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기존 "운송 예약" 텍스트와 불필요한 여백은 삭제했습니다.
              const SizedBox(height: 10),

          // 상단 검색 카드
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSearchField(Icons.search, Colors.blue, "출발지 검색"),
                  const Divider(height: 24),
                  _buildSearchField(Icons.place, Colors.red, "도착지 검색"),
                ],
              ),
            ),
          ),

          // 지도 영역
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("지도 영역")),
          ),

          const SizedBox(height: 24),

          // 화물 종류 선택
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("화물 종류", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: jimlineNavy)),
          ),
          const SizedBox(height: 12),
          _buildCategoryList(),

          const SizedBox(height: 32),

          // 예상 무게 슬라이더
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
            onChanged: (value) => setState(() => _estimatedWeight = value),
          ),

          // 예상 견적 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildPriceRow("운송 기본 요금", "${(estimatedPrice * 0.8).toInt()}원"),
                  const SizedBox(height: 12),
                  _buildPriceRow("중량 할증 (톤당)", "50,000원"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("최종 예상 견적", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "${estimatedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: jimlineNavy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


          // 예약 버튼
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 결제 화면으로 이동하면서 현재 설정된 무게와 계산된 가격 전달
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShipperPaymentView(
                        weight: _estimatedWeight,
                        price: (_estimatedWeight * 50000 + 30000).toInt(), // 견적 로직과 동일하게 설정
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: jimlineNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("운송 예약하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
    );
  }


  // 가격 행을 만드는 헬퍼 위젯
  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
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
                border: Border.all(color: isSelected ? jimlineNavy : Colors.grey[200]!, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_categories[index]["icon"], color: isSelected ? Colors.white : Colors.grey[600], size: 30),
                  const SizedBox(height: 8),
                  Text(_categories[index]["name"], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 13)),
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
        Expanded(child: TextField(decoration: InputDecoration(hintText: hint, border: InputBorder.none))),
      ],
    );

  }
}