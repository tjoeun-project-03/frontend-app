// lib/views/carrier/mypage/carrierMyPageView.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/carrier/profile_vm.dart';

class CarrierMyPageView extends ConsumerStatefulWidget {
  const CarrierMyPageView({super.key});

  @override
  ConsumerState<CarrierMyPageView> createState() => _CarrierMyPageViewState();
}

class _CarrierMyPageViewState extends ConsumerState<CarrierMyPageView> {
  final Color primaryNavy = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 프로필 정보 업데이트
    Future.microtask(() => ref.read(carrierProfileProvider.notifier).fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(carrierProfileProvider);

    if (profile.isLoading) return const Center(child: CircularProgressIndicator());

    // 🚀 Scaffold를 제거하고 SingleChildScrollView로 감싸서 부모 Scaffold 안에 배치합니다.
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 프로필 카드 (이름, 차량정보 표시)
            _buildProfileCard(profile),
            const SizedBox(height: 24),

            // 2. 차량 정보 관리 메뉴
            _buildMenuButton("차량 정보 관리", Icons.local_shipping),
            const SizedBox(height: 32),

            // 3. 누적 수익 현황 섹션
            const Text("누적 수익 현황", style: TextStyle(color: Color(0xFF1A237E), fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("₩12,450,000", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("4.2%\n최근 6개월 기준", textAlign: TextAlign.right, style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: TextButton(onPressed: () {}, child: const Text("전체 내역 상세 보기 →", style: TextStyle(color: Color(0xFF1A237E))))),
            const SizedBox(height: 24),

            // 4. 운행 통계 그리드
            const Text("운행 통계", style: TextStyle(color: Color(0xFF1A237E), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatBox("총 배송건수", "124 건", Icons.local_shipping, Colors.blue),
                _buildStatBox("이번달 완료율", "98 %", Icons.check_circle, Colors.green),
                _buildStatBox("평균 상하차 시간", "35 분", Icons.access_time, Colors.orange),
                _buildStatBox("총누적주행", "4,280 km", Icons.sync, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // 5. 불량 화주 신고 영역
            _buildReportButton(),
            const SizedBox(height: 40),

            // 6. 로그아웃 버튼 (뷰모델 연결)
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(carrierProfileProvider.notifier).logout();
                  if (context.mounted) context.go('/start');
                },
                child: const Text("로그아웃", style: TextStyle(color: Colors.redAccent, decoration: TextDecoration.underline)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(CarrierProfileState profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
            child: const Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      // decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4)),
                      // child: const Text("베테랑", style: TextStyle(color: Color(0xFF3F51B5), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("${profile.car} ${profile.carType}", style: const TextStyle(color: Colors.black54, fontSize: 14)),
                Text(profile.carNum, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                    Text(" ${profile.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(" (${profile.reviewCount})", style: const TextStyle(color: Colors.grey, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, color: primaryNavy), const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Spacer(), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    ]),
  );

  Widget _buildStatBox(String label, String value, IconData icon, Color iconColor) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const Spacer(),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildReportButton() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("불량 화주 신고", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        Text("매너 없는 화주를 리포트해주세요", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      const Spacer(), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
    ]),
  );
}