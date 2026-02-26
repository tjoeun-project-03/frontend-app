import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod 필수
import '../../viewmodels/auth/login_vm.dart';
import 'package:go_router/go_router.dart';

// 1. ConsumerStatefulWidget으로 변경하여 ref 에러 해결!
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isKeepLoggedIn = false;
  bool _isObscure = true;

  final Color primaryNavy = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    // 2. build 메서드 안에서 loginState 정의!
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("로그인", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => context.canPop() ? context.pop() : context.go('/start'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryNavy, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, size: 60, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 12),
                  Text("JimLine", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryNavy)),
                  const Text("물류의 시작과 끝, 짐라인과 함께하세요!", style: TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildLabel("아이디"),
            TextField(controller: _idController, decoration: _inputDecoration("아이디를 입력하세요")),
            const SizedBox(height: 20),

            _buildLabel("비밀번호"),
            TextField(
              controller: _pwController,
              obscureText: _isObscure,
              decoration: _inputDecoration("비밀번호를 입력하세요").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),

            Row(
              children: [
                Checkbox(value: _isKeepLoggedIn, onChanged: (val) => setState(() => _isKeepLoggedIn = val!), activeColor: primaryNavy),
                const Text("로그인 유지"),
                const Spacer(),
                TextButton(
                    onPressed: () => context.push('/role-selection'),
                    child: Text("회원가입하기", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold))
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 3. 로그인 버튼 로직 (isLoading 상태 및 라우팅 분기 처리)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loginState.isLoading ? null : () async {
                  final String? role = await ref.read(loginViewModelProvider.notifier).login(
                    _idController.text,
                    _pwController.text,
                  );

                  print("서버에서 받은 역할(Role): $role");

                  if (role != null && role.isNotEmpty) {
                    if (!mounted) return;

                    // 대소문자나 'ROLE_' 접두사 유무에 상관없이 체크하도록 수정
                    final upperRole = role.toUpperCase();
                    if (upperRole.contains("SHIPPER")) {
                      print("화주 홈으로 이동합니다!");
                      context.go('/shipper-home'); //
                    } else if (upperRole.contains("CARRIER")) {
                      print("차주 홈으로 이동합니다!");
                      context.go('/carrier-home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("정의되지 않은 사용자 역할입니다."))
                      );
                    }
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loginState.errorMessage ?? "로그인 실패"))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: loginState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("로그인", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)));
}