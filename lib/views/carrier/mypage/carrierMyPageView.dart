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

  // 숫자에 콤마 추가하는 함수
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(carrierProfileProvider);

    if (profile.isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 프로필 카드
            _buildProfileCard(profile),
            const SizedBox(height: 24),

            // 2. 관리 메뉴 리스트
            const Text("계정 및 차량 관리", style: TextStyle(color: Color(0xFF1A237E), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildMenuItem(Icons.local_shipping_outlined, "차량 정보 관리", onTap: () {}),
            
            const SizedBox(height: 32),

            // 3. 누적 수익 현황 섹션 (실시간 계산값 반영)
            const Text("누적 수익 현황", style: TextStyle(color: Color(0xFF1A237E), fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₩${_formatPrice(profile.totalIncome)}", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("실시간 집계", textAlign: TextAlign.right, 
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 32),

            // 4. 운행 통계 그리드 (실시간 계산값 반영)
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
                _buildStatBox("총 배송건수", "${profile.totalOrders} 건", Icons.local_shipping, Colors.blue),
                _buildStatBox("이번달 완료율", "${profile.completionRate.toStringAsFixed(1)} %", Icons.check_circle, Colors.green),
                _buildStatBox("평균 소요 시간", "${profile.avgTime} 분", Icons.access_time, Colors.orange),
                _buildStatBox("총누적주행", "${profile.totalDistance.toStringAsFixed(1)} km", Icons.sync, Colors.purple),
              ],
            ),
            const SizedBox(height: 40),

            // 6. 로그아웃 버튼
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
                Text(profile.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: primaryNavy, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

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
}
