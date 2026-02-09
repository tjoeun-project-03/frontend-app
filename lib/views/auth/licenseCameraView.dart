import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart'; // 전역변수 cameras를 가져옵니다.
import '../../widgets/licenseAuthDialog.dart';

class LicenseCameraView extends StatefulWidget {
  const LicenseCameraView({super.key});

  @override
  State<LicenseCameraView> createState() => _LicenseCameraViewState();
}

class _LicenseCameraViewState extends State<LicenseCameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // 후면 카메라 선택 및 고화질 설정
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("자격증 촬영", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 1. 카메라 라이브 뷰
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller),
                ),

                // 2. 촬영 가이드 (반투명 오버레이)
                _buildGuideOverlay(context),

                // 3. 하단 텍스트 및 셔터 버튼
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        "가이드 영역에 자격증을 맞춰주세요",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await _initializeControllerFuture;
                            // 사진 촬영 및 임시 저장
                            final image = await _controller.takePicture();

                            if (!mounted) return;
                            // 촬영 성공 시 완료 알림 띄우기
                            _showCompleteDialog(context, jimlineNavy);
                          } catch (e) {
                            debugPrint("촬영 오류: $e");
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const CircleAvatar(backgroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
        },
      ),
    );
  }

  // 자격증 영역만 밝게 보이게 하는 가이드 마스크
  Widget _buildGuideOverlay(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.6),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.85 * 0.63,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 방지
      builder: (context) => LicenseAuthDialog(primaryColor: color),
    );
  }


}