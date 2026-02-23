import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/signup_vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/driverAuthModal.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';

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

  final _postcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  // 상태 변수
  String _selectedGender = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true; // 추가

  final Color jimlineNavy = const Color(0xFF1A2B88);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _postcodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // 텍스트가 바뀔 때마다 VM에 알려 유효성 업데이트
  void _onInputChanged() {
    ref.read(signupViewModelProvider.notifier).validateForm(
      name: _nameController.text,
      phone: _phoneController.text,
      id: _idController.text,
      password: _passwordController.text,
      address: _addressController.text,
    );
  }

  void _searchAddress() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressSearchPage()),
    );

    if (result != null) {
      setState(() {
        _postcodeController.text = result.zonecode;
        _addressController.text = result.address;
      });
      _onInputChanged(); // 주소 입력 후 유효성 갱신
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupViewModelProvider);

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
              Text("반가워요🖐️", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: jimlineNavy)),
              const SizedBox(height: 8),
              const Text("짐라인(JimLine)의 원활한 운송 서비스를 위해\n상세 정보를 입력해주세요.", style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 32),

              _buildLabel("이름"),
              _buildTextField(_nameController, "성함을 입력해주세요", onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("전화번호"),
              _buildTextField(_phoneController, "010-0000-0000", keyboardType: TextInputType.phone, onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("성별"),
              Row(
                children: [
                  Expanded(child: _buildGenderButton("남성")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderButton("여성")),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel("아이디"),
              Row(
                children: [
                  Expanded(child: _buildTextField(_idController, "아이디 입력 (8자 이상)", onChanged: (_) => _onInputChanged())),
                  const SizedBox(width: 12),
                  _buildSideButton("중복 확인", onPressed: () {
                    // TODO: 아이디 중복 확인 로직
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // 비밀번호
              _buildLabel("비밀번호"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => _onInputChanged(),
                      decoration: _inputDecoration("영문, 숫자 포함 8자 이상").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSideButton("중복 확인", onPressed: () {
                    ref.read(signupViewModelProvider.notifier).checkPasswordDuplication(_passwordController.text);
                  }),
                ],
              ),

              // 중복 확인 완료 시 메시지 표시
              if (signupState.isPasswordChecked)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Text("✅ 사용 가능한 비밀번호입니다.", style: TextStyle(color: Colors.green, fontSize: 13)),
                ),
              const SizedBox(height: 24),


              _buildLabel("이메일 주소"),
              _buildTextField(_emailController, "example@jimline.com", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),

              _buildLabel("주소 설정"),
              Row(
                children: [
                  Expanded(child: _buildTextField(_postcodeController, "우편번호", readOnly: true)),
                  const SizedBox(width: 12),
                  _buildSideButton("주소 찾기", onPressed: _searchAddress),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_addressController, "주소", readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(_detailAddressController, "상세 주소"),
              const SizedBox(height: 48),

              // 가입 완료 버튼 (유효성 상태에 따라 활성화/비활성화)
              ElevatedButton(
                onPressed: signupState.isFormValid ? () {
                  if(signupState.selectedRole == UserRole.driver) {
                    DriverAuthModal.show(context);
                  } else {
                    context.go('/shipper-home');
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: signupState.isFormValid ? jimlineNavy : Colors.grey[400],
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

  // --- 공통 헬퍼 위젯 ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: jimlineNavy)),
    );
  }

  // 공통 사이드 버튼 (중복확인, 일치확인, 주소찾기 디자인 통일)
  Widget _buildSideButton(String text, {required VoidCallback onPressed}) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: jimlineNavy),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold)),
      ),
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

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType, bool readOnly = false, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
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
      child: Text(gender, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }
}

// 주소 검색 페이지 위젯
class AddressSearchPage extends StatelessWidget {
  const AddressSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("주소 검색"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2B88),
        elevation: 0,
      ),
      body: DaumPostcodeView(
        onComplete: (model) {
          Navigator.pop(context, model);
        },
      ),
    );
  }
}