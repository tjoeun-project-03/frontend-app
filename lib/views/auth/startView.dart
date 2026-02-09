import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A237E); // 디자인 가이드 네이비

    return Scaffold(
      backgroundColor: Colors.white, // 흰색 배경으로 수정
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단 로고 영역
              Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/truck_logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "JimLine",
                    style: TextStyle(
                      color: primaryNavy,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // 중앙 일러스트 (배경 원형 포함)
              Center(
                child: Container(
                  width: 300,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E3E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.8, // 원 안에서 이미지가 적당한 크기를 유지하도록 조절
                    child: Image.asset(
                      'assets/images/start_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 하단 버튼 영역
              Column(
                children: [
                  const Text(
                    "스마트한 화물 운송의 시작",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryNavy, // 네이비 버튼
                        foregroundColor: Colors.white, // 흰색 글자
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "시작하기",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}