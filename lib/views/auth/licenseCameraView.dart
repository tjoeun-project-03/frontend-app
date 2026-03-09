import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../services/auth/license_service.dart';
import '../../viewmodels/auth/signup_vm.dart';
import '../../viewmodels/auth/login_vm.dart'; // 🚀 자동 로그인 상태 확인을 위해 추가

class LicenseCameraView extends ConsumerStatefulWidget {
  final Map<String, dynamic> signupData;
  const LicenseCameraView({super.key, required this.signupData});

  @override
  ConsumerState<LicenseCameraView> createState() => _LicenseCameraViewState();
}

class _LicenseCameraViewState extends ConsumerState<LicenseCameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCapturePressed() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      // 1. 파이썬 서버 자격증 검증
      final result = await LicenseService().verifyLicense(image.path);

      if (result['status'] == 'success') {
        // 2. 자격증 성공 시, 실제 회원가입 진행
        final signupNotifier = ref.read(signupViewModelProvider.notifier);

        final Map<String, dynamic> finalData = {
          ...widget.signupData,
          "license": "VERIFIED",
          "accepted": 1,
        };

        // 🚀 핵심: autoLogin: true 옵션 추가
        String? error = await signupNotifier.registerUser(finalData, autoLogin: true);

        if (!mounted) return;
        Navigator.pop(context); // 로딩창 닫기

        if (error == null) {
          // ✅ 가입 및 자동 로그인 성공!
          _showCompleteDialog(context, const Color(0xFF1A2B88), "인증 및 가입이 완료되었습니다.");
          
          Future.delayed(const Duration(seconds: 2), () {
            // 🚀 로그인 뷰모델의 상태를 보고 올바른 메인으로 이동
            final role = ref.read(loginViewModelProvider).userRole;
            if (role == 'ROLE_CARRIER') {
              context.go('/carrier-home');
            } else {
              context.go('/login');
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      } else {
        Navigator.pop(context); // 로딩창 닫기
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "인증 실패")));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      debugPrint("❌ 최종 가입 단계 오류 상세: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text("자격증 촬영", style: TextStyle(color: Colors.white))),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(width: double.infinity, height: double.infinity, child: CameraPreview(_controller)),
                _buildGuideOverlay(context),
                Positioned(
                  bottom: 60, left: 0, right: 0,
                  child: Column(children: [
                    const Text("가이드 영역에 자격증을 맞춰주세요", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _onCapturePressed,
                      child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: const CircleAvatar(backgroundColor: Colors.white)),
                    ),
                  ]),
                ),
              ],
            );
          } else { return const Center(child: CircularProgressIndicator()); }
        },
      ),
    );
  }

  Widget _buildGuideOverlay(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcOut),
      child: Stack(children: [
        Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
        Align(alignment: Alignment.center, child: Container(width: MediaQuery.of(context).size.width * 0.85, height: MediaQuery.of(context).size.width * 0.85 * 0.63, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
      ]),
    );
  }

  void _showCompleteDialog(BuildContext context, Color color, String msg) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      title: const Text("성공"),
      content: Text(msg),
    ));
  }
}
