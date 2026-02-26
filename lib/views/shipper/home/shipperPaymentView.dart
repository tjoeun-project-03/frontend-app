import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShipperPaymentView extends StatelessWidget {
  final double weight;
  final int price;
  // 🚀 추가된 필드들
  final String startAddress;
  final String endAddress;
  final String category;

  const ShipperPaymentView({
    super.key,
    required this.weight,
    required this.price,
    required this.startAddress,
    required this.endAddress,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: jimlineNavy),
          onPressed: () => Navigator.pop(context), // 뒤로 가기
        ),
        title: const Text(
          "운송 신청 및 결제",
          style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 운송 요약 정보 카드 (데이터 매핑 완료)
            const Text("운송 요약", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("출발지", startAddress), // 🚀 실제 주소
                  const SizedBox(height: 12),
                  _buildSummaryRow("도착지", endAddress),   // 🚀 실제 주소
                  const SizedBox(height: 12),
                  _buildSummaryRow("화물 정보", "$category / ${weight.toStringAsFixed(1)} 톤"), // 🚀 실제 카테고리
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. 결제 수단 선택
            const Text("결제 수단", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentOption(Icons.credit_card, "신용/체크카드", true),
            _buildPaymentOption(Icons.account_balance_wallet, "계좌이체", false),
            _buildPaymentOption(Icons.payment, "간편결제 (짐라인페이)", false),

            const SizedBox(height: 40),

            // 3. 최종 결제 금액 정보
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("총 결제 금액", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: jimlineNavy),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 결제하기 버튼
            ElevatedButton(
              onPressed: () => _showSuccessDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: jimlineNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("결제 및 운송 신청하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 헬퍼 위젯들
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildPaymentOption(IconData icon, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? const Color(0xFF1A2B88) : Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFF1A2B88).withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF1A2B88) : Colors.grey),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF1A2B88)),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("신청 완료"),
        content: const Text("운송 신청이 완료되었습니다.\n차주님이 배정되면 알림을 드릴게요!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/shipper-home');
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }
}