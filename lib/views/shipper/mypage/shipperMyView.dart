import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jimline/viewmodels/shipper/profile_vm.dart';

class ShipperMyView extends ConsumerWidget {
  const ShipperMyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 프로필 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: jimlineNavy.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 40, color: jimlineNavy),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profileState.userName}님",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileState.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. 운송 현황 요약 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem("예약 중", "2"),
                    _buildDivider(),
                    _buildSummaryItem("운송 중", "1"),
                    _buildDivider(),
                    _buildSummaryItem("완료", "15"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. 🚀 운송 관리 메뉴 섹션 (추가됨)
            _buildMenuSection("운송 관리", [
              _buildMenuItem(
                Icons.description_outlined,
                "운송 예약 내역",
                onTap: () => context.push('/shipper/order-history'), // 내역 페이지로 이동
              ),
              _buildMenuItem(Icons.payment_outlined, "결제 수단 관리"),
              _buildMenuItem(Icons.location_on_outlined, "자주 쓰는 주소"),
            ]),

            const SizedBox(height: 12),

            // 4. 고객 지원 메뉴 섹션
            _buildMenuSection("고객 지원", [
              _buildMenuItem(Icons.campaign_outlined, "공지사항"),
              _buildMenuItem(Icons.headset_mic_outlined, "1:1 문의"),
              _buildMenuItem(Icons.help_outline, "자주 묻는 질문"),
            ]),

            const SizedBox(height: 40),

            // 5. 로그아웃 버튼
            TextButton(
              onPressed: () async {
                final bool success = await ref.read(profileViewModelProvider.notifier).logout();
                if (success && context.mounted) {
                  context.go('/start');
                }
              },
              child: const Text(
                  "로그아웃",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 헬퍼 위젯들 ---

  Widget _buildSummaryItem(String label, String count) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B88))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  // 🚀 클릭 기능을 위해 onTap 파라미터를 추가한 메뉴 아이템 위젯
  Widget _buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A2B88), size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap, // 넘겨받은 클릭 함수 연결
    );
  }
}