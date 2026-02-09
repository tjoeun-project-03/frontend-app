import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'app.dart';

// 사용 가능한 카메라 목록을 전역변수로 관리
late List<CameraDescription> cameras;

Future<void> main() async {
  // 1. 플러터 엔진과 상호작용하기 위해 반드시 필요
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 사용 가능한 카메라 장치 목록 가져오기
  cameras = await availableCameras();

  runApp(
    const ProviderScope(
      child: JimlineApp(),
    ),
  );
}