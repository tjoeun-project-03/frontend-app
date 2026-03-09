import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottomNavBar.dart';

class ShipperFaqView extends StatelessWidget {
  const ShipperFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color bgGrey = Color(0xFFF8F9FA);

    final List<Map<String, String>> faqList = [
      {
        "question": "배송 예약은 어떻게 하나요?",
        "answer": "홈 화면에서 출발지와 도착지, 물품 정보를 입력하신 후 '예약하기' 버튼을 누르면 배차가 진행됩니다. 배차가 완료되면 알림으로 안내해 드립니다."
      },
      {
        "question": "운송 현황은 어디서 확인하나요?",
        "answer": "하단 네비게이션 바의 '운송관리' 탭이나 마이페이지의 '이용 내역'에서 실시간 위치 및 현재 상태를 확인하실 수 있습니다."
      },
      {
        "question": "결제 수단 변경이 가능한가요?",
        "answer": "예약 단계에서 결제 수단을 선택하실 수 있습니다. 이미 결제가 완료된 건은 취소 후 다시 예약하셔야 하니 유의 부탁드립니다."
      },
      {
        "question": "영수증 발급은 어떻게 받나요?",
        "answer": "운송 완료 후 '운송 예약 내역'에서 해당 건을 선택하시면 상세 화면 하단에서 전자 영수증을 확인 및 다운로드하실 수 있습니다."
      },
      {
        "question": "기사님과 연락하고 싶어요.",
        "answer": "매칭된 운송 건의 상세 페이지에서 '기사님께 연락하기' 버튼을 통해 채팅 또는 전화 연결이 가능합니다."
      },
      {
        "question": "회원 탈퇴는 어떻게 하나요?",
        "answer": "마이페이지 하단의 '로그아웃' 버튼 옆 혹은 고객센터 1:1 문의를 통해 탈퇴 요청을 주시면 확인 후 처리해 드립니다."
      },
    ];

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "자주 묻는 질문",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: faqList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          final faq = faqList[index];
          return Container(
            color: Colors.white,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              leading: const Text(
                "Q",
                style: TextStyle(
                  color: jimlineNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(52, 16, 20, 16),
                  child: Text(
                    faq['answer']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pop();
          } else {
            context.go('/shipper-home');
          }
        },
      ),
    );
  }
}
