import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';

class JimlineApp extends ConsumerWidget {
  const JimlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Jimline',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        // 폰트 설정이 따로 없다면 아래 줄은 주석 처리하거나 지워주세요.
        // fontFamily: 'Pretendard',

        primaryColor: const Color(0xFF1A2B88), // 딥 네이비
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A2B88),
          primary: const Color(0xFF1A2B88),
          surface: Colors.white,
        ),

        // 버튼 등 공통 테마 설정
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A2B88),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
          ),
        ),
        ),
      ),
      routerConfig: router,
    );
  }
}