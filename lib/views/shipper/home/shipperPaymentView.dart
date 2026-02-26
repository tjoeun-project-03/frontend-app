import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jimline/viewmodels/shipper/order_vm.dart';
import 'package:jimline/views/shipper/home/tossPaymentWebView.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../main.dart';

class ShipperPaymentView extends ConsumerStatefulWidget {
  final double weight;
  final int price;
  final String startAddress;
  final String endAddress;
  final String category;
  final double distance;
  final int duration;
  final String startLat, startLng, endLat, endLng;

  const ShipperPaymentView({
    super.key,
    required this.weight, required this.price,
    required this.startAddress, required this.endAddress,
    required this.category, required this.distance,
    required this.duration, required this.startLat,
    required this.startLng, required this.endLat, required this.endLng,
  });

  @override
  ConsumerState<ShipperPaymentView> createState() => _ShipperPaymentViewState();
}

class _ShipperPaymentViewState extends ConsumerState<ShipperPaymentView> {
  // 수취인 정보를 위한 컨트롤러
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    final isLoading = ref.watch(orderViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: jimlineNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text("운송 신청 및 결제", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 수취인 정보 입력
            const Text("수취인 정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "받는 사람 이름",
                    hintText: "홍길동",
                    border: OutlineInputBorder()
                )
            ),
            const SizedBox(height: 10),
            TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                    labelText: "연락처",
                    hintText: "예: 010-1234-5678",
                    border: OutlineInputBorder()
                )
            ),

            // 2. 운송 요약 정보
            const Text("운송 요약", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _buildSummaryRow("출발지", widget.startAddress),
                _buildSummaryRow("도착지", widget.endAddress),
                _buildSummaryRow("화물 정보", "${widget.category} / ${widget.weight.toStringAsFixed(1)} 톤"),
                _buildSummaryRow("이동 거리", "${widget.distance.toStringAsFixed(1)} km"),
              ]),
            ),

            const SizedBox(height: 32),

            // 3. 🚀 복구된 결제 수단 선택 섹션
            const Text("결제 수단", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentOption(Icons.credit_card, "신용/체크카드", true),
            _buildPaymentOption(Icons.account_balance_wallet, "계좌이체", false),
            _buildPaymentOption(Icons.payment, "간편결제 (짐라인페이)", false),

            const SizedBox(height: 32),

            // 4. 🚀 복구된 최종 결제 금액 섹션
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
                    "${widget.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: jimlineNavy),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 결제 및 신청 버튼
            ElevatedButton(
              onPressed: isLoading ? null : _handleOrderSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: jimlineNavy,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("결제 및 운송 신청하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 결제 수단 옵션 빌더
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

  void _handleOrderSubmit() async {
    // 1. 수취인 정보 체크
    if (_nameController.text.isEmpty || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("수취인 정보를 입력해주세요.")));
      return;
    }

    // 2. 🚀 서버에서 중복 없는 "진짜" 인보이스 번호 받아오기
    final String? confirmedInvoiceNo = await ref.read(orderViewModelProvider.notifier).getNewInvoiceNo();

    if (confirmedInvoiceNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("번호 생성 실패. 다시 시도해주세요.")));
      return;
    }

    // 3. 서버가 준 번호를 토스에 던지기
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TossPaymentWebView(
          orderId: confirmedInvoiceNo, // 👈 서버가 보장한 중복 없는 번호!
          orderName: "${widget.category} 운송",
          amount: widget.price,
        ),
      ),
    );

    // 4. 결제 성공 후 최종 저장 요청 (전달받은 번호 그대로 사용)
    if (result != null && result is Map<String, String?>) {
      _requestFinalOrderCreation(
          result['paymentKey']!,
          result['orderId']!,
          int.parse(result['amount']!)
      );
    }
  }

// 4. 서버(Spring)에 결제 승인 + DB 저장을 한꺼번에 요청
  void _requestFinalOrderCreation(String paymentKey, String orderId, int amount) async {
    final success = await ref.read(orderViewModelProvider.notifier).createOrder({
      "paymentKey": paymentKey, // 추가
      "invoiceNo": orderId,       // 추가
      "price": amount,         // 추가
      "consigneeName": _nameController.text,
      "consigneeContact": _contactController.text,
      "departure": widget.startAddress,
      "arrival": widget.endAddress,
      "weight": widget.weight,
      "content": widget.category,
      "duration": widget.duration,
      "distance": widget.distance,
      "startLat": widget.startLat,
      "startLng": widget.startLng,
      "endLat": widget.endLat,
      "endLng": widget.endLng,
      "carType": widget.weight <= 1.0 ? "1t" : widget.weight <= 5.0 ? "5t" : "11t",
    });

    if (success && mounted) {
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    // 키보드부터 무조건 닫기
    FocusManager.instance.primaryFocus?.unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("신청 완료"),
        content: const Text("운송 예약이 정상 신청되었습니다!"),
        actions: [
          TextButton(
            onPressed: () {
              // 1. 다이얼로그 닫기
              Navigator.of(dialogContext).pop();
              
              // 2. ShipperPaymentView 닫기 (true 반환 = 후속 작업 요청)
              Navigator.of(context).pop(true);
            },
            child: const Text("확인"),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)))
    ]),
  );
}