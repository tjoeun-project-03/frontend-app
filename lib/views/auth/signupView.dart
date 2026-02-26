import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/signup_vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});
  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  // 컨트롤러 정의
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _carController = TextEditingController();
  final _carNumController = TextEditingController();

  final Color jimlineNavy = const Color(0xFF1A2B88);
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose(); _idController.dispose();
    _passwordController.dispose(); _emailController.dispose(); _postcodeController.dispose();
    _addressController.dispose(); _detailAddressController.dispose(); _carController.dispose();
    _carNumController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    ref.read(signupViewModelProvider.notifier).validateForm(
      name: _nameController.text, phone: _phoneController.text, email: _emailController.text,
      id: _idController.text, password: _passwordController.text,
      zipcode: _postcodeController.text, address: _addressController.text,
      car: _carController.text, carNum: _carNumController.text,
    );
  }

  void _searchAddress() async {
    final dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressSearchPage()));
    if (result != null) {
      setState(() { _postcodeController.text = result.zonecode; _addressController.text = result.address; });
      _onInputChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupViewModelProvider);
    final isDriver = signupState.selectedRole == UserRole.driver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: Text("회원가입", style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("상세 정보 입력", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: jimlineNavy)),
              const SizedBox(height: 32),

              _buildLabel("이름"),
              _buildTextField(_nameController, "성함 입력", onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("전화번호"),
              _buildTextField(_phoneController, "010-0000-0000", onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("이메일 주소 (필수)"),
              _buildTextField(_emailController, "example@naver.com", onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("아이디 (8자 이상)"),
              _buildTextField(_idController, "사용하실 아이디를 입력해주세요", onChanged: (_) => _onInputChanged()),
              const SizedBox(height: 24),

              _buildLabel("비밀번호 (8자 이상)"),
              TextField(
                controller: _passwordController, obscureText: _obscurePassword, onChanged: (_) => _onInputChanged(),
                decoration: _inputDecoration("영문, 숫자 포함 8자 이상").copyWith(
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel("주소 설정"),
              Row(children: [Expanded(child: _buildTextField(_postcodeController, "우편번호", readOnly: true)), const SizedBox(width: 12), _buildSideButton("주소 찾기", onPressed: _searchAddress)]),
              const SizedBox(height: 12),
              _buildTextField(_addressController, "주소", readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(_detailAddressController, "상세 주소를 입력해주세요", onChanged: (_) => _onInputChanged()),

              if (isDriver) ...[
                const SizedBox(height: 32), const Divider(thickness: 1), const SizedBox(height: 24),
                _buildLabel("차량 정보"),
                _buildTextField(_carController, "차량 명칭 (예: 현대 포터2)", onChanged: (_) => _onInputChanged()),
                const SizedBox(height: 16),
                _buildTextField(_carNumController, "차량 번호 (예: 12가 3456)", onChanged: (_) => _onInputChanged()),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: signupState.carType, decoration: _inputDecoration("차종 선택"),
                  items: ["1T", "1.4T", "2.5T", "3T", "5T"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) { ref.read(signupViewModelProvider.notifier).updateCarType(val!); _onInputChanged(); },
                ),
                CheckboxListTile(title: const Text("냉동/냉장 차량 여부"), value: signupState.freezer == 1, activeColor: jimlineNavy, onChanged: (val) { ref.read(signupViewModelProvider.notifier).toggleFreezer(val!); _onInputChanged(); }),
              ],

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: signupState.isFormValid ? () async {
                  final Map<String, dynamic> requestData = {
                    "userId": _idController.text, "userPw": _passwordController.text, "userName": _nameController.text,
                    "email": _emailController.text, "phone": _phoneController.text, "zipcode": _postcodeController.text,
                    "address": _addressController.text, "detailAddress": _detailAddressController.text, "corpReg": null,
                  };

                  if (isDriver) {
                    requestData.addAll({"car": _carController.text, "carNum": _carNumController.text, "carType": signupState.carType, "freezer": signupState.freezer, "license": "PENDING", "carReg": "PENDING"});
                    _showLicenseGuide(context, requestData);
                  } else {
                    // 가입 요청 및 서버 에러 처리
                    String? error = await ref.read(signupViewModelProvider.notifier).registerUser(requestData);
                    if (!mounted) return;
                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원가입 완료! 로그인해주세요. 🎉")));
                      context.go('/login');
                    } else {
                      // 서버가 던진 "이미 존재하는 아이디입니다." 등의 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  }
                } : null,
                style: ElevatedButton.styleFrom(backgroundColor: signupState.isFormValid ? jimlineNavy : Colors.grey[400], minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text(isDriver ? "다음 (자격증 촬영)" : "가입 완료", style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLicenseGuide(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => Container(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.contact_page_outlined, size: 64, color: jimlineNavy), const SizedBox(height: 16), const Text("차주이신가요?\n자격증을 준비해주세요!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 32), SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () { Navigator.pop(context); context.push('/license-camera', extra: data); }, style: ElevatedButton.styleFrom(backgroundColor: jimlineNavy), child: const Text("촬영 시작하기", style: TextStyle(color: Colors.white, fontSize: 16))))])));
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: jimlineNavy)));
  Widget _buildTextField(TextEditingController ctrl, String hint, {bool readOnly = false, Function(String)? onChanged}) => TextField(controller: ctrl, readOnly: readOnly, onChanged: onChanged, decoration: _inputDecoration(hint));
  Widget _buildSideButton(String text, {required VoidCallback onPressed}) => SizedBox(height: 56, child: OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(side: BorderSide(color: jimlineNavy), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(text, style: TextStyle(color: jimlineNavy, fontWeight: FontWeight.bold))));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(16), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: jimlineNavy)));
}

class AddressSearchPage extends StatelessWidget {
  const AddressSearchPage({super.key});
  @override
  Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("주소 검색"), backgroundColor: Colors.white, foregroundColor: const Color(0xFF1A2B88), elevation: 0), body: DaumPostcodeView(onComplete: (model) { Navigator.pop(context, model); })); }
}