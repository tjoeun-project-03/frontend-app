import 'package:flutter/material.dart';

class ShipperEvaluationView extends StatefulWidget {
  const ShipperEvaluationView({super.key});

  @override
  State<ShipperEvaluationView> createState() => _ShipperEvaluationViewState();
}

class _ShipperEvaluationViewState extends State<ShipperEvaluationView> {
  int _rating = 0;
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color borderGrey = Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("운송 종료", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 하차 완료 헤더
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF34C759), size: 20),
                const SizedBox(width: 6),
                const Text("하차 완료", style: TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text("운송이 완료되었습니다", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("2023년 10월 24일 14:30 · 주문번호 JG-88293", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // 2. 담당 기사 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("담당기사", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("김철수 기사님", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("서울 12가 3456 · 5톤 카고", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 3. 별점 및 태그 섹션
            const Center(child: Text("기사님 서비스는 어떠셨나요?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jimlineNavy))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 44),
              )),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                spacing: 10, runSpacing: 10,
                children: ["시간을 엄수해요", "매우 친절해요", "짐이 안전해요", "연락이 잘 돼요"].map((tag) => _buildTag(tag)).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // 4. 후기 및 문제 신고
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "운송에 대한 후기를 남겨주세요 (선택사항)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderGrey)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: borderGrey)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text("배송 물품에 문제가 있나요?", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text("신고하기", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline))),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // 5. 종합 평점 그래프
            const Text("기사님 종합 평점", style: TextStyle(fontWeight: FontWeight.bold, color: jimlineNavy)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Column(
                  children: [
                    Text("4.8", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14)]),
                    Text("12 reviews", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingRow("5", 0.85),
                      _buildRatingRow("4", 0.10),
                      _buildRatingRow("3", 0.05),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 6. 하단 버튼
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: jimlineNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("평가 제출 및 운송 종료", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    bool isSelected = _selectedTags.contains(label);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => val ? _selectedTags.add(label) : _selectedTags.remove(label)),
      selectedColor: const Color(0xFF1A2B88),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildRatingRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: LinearProgressIndicator(value: value, backgroundColor: const Color(0xFFEEEEEE), color: const Color(0xFF1A2B88), minHeight: 6)),
          const SizedBox(width: 8),
          Text("${(value * 100).toInt()}%", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}