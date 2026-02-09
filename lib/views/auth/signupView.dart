import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/signup_vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/driverAuthModal.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  // 컨트롤러 설정
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // 상태 변수
  String _selectedGender = "";
  bool _obscurePassword = true; // 비밀번호 숨김 상태

  final Color jimlineNavy = const Color(0xFF1A2B88);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: jimlineNavy),
          onPressed: () => context.pop(),
        ),
        title: Text("회원가입", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("반가워요!🖐️", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: jimlineNavy)),
              const SizedBox(height: 8),
              const Text("짐라인(JimLine)의 원활한 운송 서비스를 위해\n상세 정보를 입력해주세요.", style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 32),

              // 1. 이름
              _buildLabel("이름"),
              _buildTextField(_nameController, "성함을 입력해주세요"),
              const SizedBox(height: 24),

              // 2. 전화번호
              _buildLabel("전화번호"),
              _buildTextField(_phoneController, "010-0000-0000", keyboardType: TextInputType.phone),
              const SizedBox(height: 24),

              // 3. 성별
              _buildLabel("성별"),
              Row(
                children: [
                  Expanded(child: _buildGenderButton("남성")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderButton("여성")),
                ],
              ),
              const SizedBox(height: 24),

              // 4. 아이디 (중복 확인 버튼 포함)
              _buildLabel("아이디"),
              Row(
                children: [
                  Expanded(child: _buildTextField(_idController, "아이디 입력 (8자 이상)")),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 아이디 중복 확인 로직
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: jimlineNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("중복 확인", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. 비밀번호 (눈 아이콘 토글 포함)
              _buildLabel("비밀번호"),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration("영문, 숫자 포함 8자 이상").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. 이메일 주소
              _buildLabel("이메일 주소"),
              _buildTextField(_emailController, "example@jimline.com", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),


              const SizedBox(height: 48),

              // 가입 완료 버튼
              ElevatedButton(
                onPressed: () {
                  final selectedRole = ref.read(signupViewModelProvider); // 현재 선택된 역할 확인

                  if(selectedRole == UserRole.driver) {
                    // 차주인 경우 모달 띄우기
                    DriverAuthModal.show(context);
                  } else {
                    context.go('/start');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: jimlineNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("가입 완료", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- 소형 위젯 모듈화 ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: jimlineNavy)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: jimlineNavy, width: 1.5),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return OutlinedButton(
      onPressed: () => setState(() => _selectedGender = gender),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? jimlineNavy : Colors.white,
        side: BorderSide(color: isSelected ? jimlineNavy : Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        gender,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}