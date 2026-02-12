import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // 백엔드 연동을 위한 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isKeepLoggedIn = false;
  bool _isObscure = true;

  final Color primaryNavy = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "로그인",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/start');
            }
          }
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 로고 및 슬로건
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryNavy, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/truck_logo.png', height: 60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "JimLine",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryNavy),
                  ),
                  const Text(
                    "물류의 시작과 끝, 짐라인과 함께하세요!",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. 아이디 입력창
            _buildLabel("아이디"),
            TextField(
              controller: _idController,
              decoration: _inputDecoration("아이디 또는 이메일을 입력하세요"),
            ),
            const SizedBox(height: 20),

            // 3. 비밀번호 입력창
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

            // 4. 로그인 유지 및 링크
            Row(
              children: [
                Checkbox(
                  value: _isKeepLoggedIn,
                  onChanged: (val) => setState(() => _isKeepLoggedIn = val!),
                  activeColor: primaryNavy,
                ),
                const Text("로그인 유지"),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text("아이디 찾기", style: TextStyle(color: Colors.black54))),
                const Text("|", style: TextStyle(color: Colors.black26)),
                TextButton(
                      onPressed: () {
                      context.push('/role-selection');
                }, child: Text("회원가입하기", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 30),

            // 5. 로그인 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: ViewModel을 통해 Spring Boot API 호출
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("로그인", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
    );
  }
}