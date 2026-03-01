import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/signup_vm.dart';

class RoleSelectionView extends ConsumerWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupViewModelProvider);
    final selectedRole = signupState.selectedRole;

    const Color primaryNavy = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text("회원가입", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("반갑습니다!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryNavy)),
            const Text("어떤 목적으로 이용하시나요?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 12),
            const Text("회원 유형에 따라 맞춤 서비스를 제공합니다.", style: TextStyle(color: Colors.black, fontSize: 16)),
            const SizedBox(height: 20),

            // 화주 선택 카드
            _buildRoleCard(
              context,
              ref,
              role: UserRole.shipper,
              title: "화주 (Shipper)",
              description: "신속하고 안전하게 화물을\n보내고 싶어요!",
              imagePath: 'assets/images/boxes.png',
              isSelected: selectedRole == UserRole.shipper,
            ),
            const SizedBox(height: 10),

            // 차주 선택 카드
            _buildRoleCard(
              context,
              ref,
              role: UserRole.driver,
              title: "차주 (Driver)",
              description: "나에게 꼭 맞는 최적의 일감을\n찾고 싶어요!",
              imagePath: 'assets/images/truck_delivery.png',
              isSelected: selectedRole == UserRole.driver,
            ),

            const Spacer(),

            // 다음 단계 버튼
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: selectedRole != UserRole.none
                    ? () => context.push('/signup') // 다음 상세 정보 입력 화면으로
                    : null, // 선택 안됐을 시 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("다음 단계로 이동", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("이미 계정이 있으신가요? 로그인", style: TextStyle(color: primaryNavy)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, WidgetRef ref,
      {required UserRole role, required String title, required String description,
        required String imagePath, required bool isSelected}) {
    const Color primaryNavy = Color(0xFF1A237E);

    return GestureDetector(
      onTap: () => ref.read(signupViewModelProvider.notifier).selectRole(role),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? primaryNavy : Colors.black, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(role == UserRole.shipper ? Icons.inventory_2 : Icons.local_shipping, color: primaryNavy),
                          const SizedBox(width: 8),
                          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(description, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryNavy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSelected ? "선택됨" : "선택하기",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(imagePath, width: 100), // 시안의 이미지 배치
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: primaryNavy,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}