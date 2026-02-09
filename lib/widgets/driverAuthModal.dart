import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverAuthModal {
  static void show(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 배경을 투명하게 해야 곡률이 보입니다.
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: jimlineNavy),
            const SizedBox(height: 16),
            const Text(
              "차주이신가요?\n자격증을 준비해주세요!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: jimlineNavy
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "안전한 서비스를 위해 화물운송종사자\n자격증 촬영이 필요합니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.pop(); // 모달 닫기
                context.push('/license-camera'); // 카메라 페이지로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: jimlineNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("촬영 시작하기", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}