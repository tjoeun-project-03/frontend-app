import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/common/notification_service.dart';

// 앱 어디서든 접근 가능한 전역 네비게이터 키 생성
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 사용 가능한 카메라 목록을 전역변수로 관리
late List<CameraDescription> cameras;

Future<void> main() async {
  // 1. 플러터 엔진과 상호작용하기 위해 반드시 필요
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ 환경 변수 로드 성공");
  } catch (e) {
    debugPrint("❌ .env 파일을 찾을 수 없습니다: $e");
  }

  // 2. 사용 가능한 카메라 장치 목록 가져오기
  cameras = await availableCameras();

  // 알림 서비스 초기화
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: JimlineApp(),
    ),
  );
}