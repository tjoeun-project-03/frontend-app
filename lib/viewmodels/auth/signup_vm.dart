import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UserRole { none, shipper, driver }

class SignupState {
  final UserRole selectedRole;
  final bool isFormValid;
  final String carType;
  final int freezer;

  SignupState({
    this.selectedRole = UserRole.none,
    this.isFormValid = false,
    this.carType = "1T",
    this.freezer = 0,
  });

  SignupState copyWith({
    UserRole? selectedRole,
    bool? isFormValid,
    String? carType,
    int? freezer,
  }) {
    return SignupState(
      selectedRole: selectedRole ?? this.selectedRole,
      isFormValid: isFormValid ?? this.isFormValid,
      carType: carType ?? this.carType,
      freezer: freezer ?? this.freezer,
    );
  }
}

class SignupViewModel extends StateNotifier<SignupState> {
  SignupViewModel() : super(SignupState());

  void selectRole(UserRole role) => state = state.copyWith(selectedRole: role);
  void updateCarType(String type) => state = state.copyWith(carType: type);
  void toggleFreezer(bool isFreezer) => state = state.copyWith(freezer: isFreezer ? 1 : 0);

  // 1. 단순 양식 검사 (아이디/비번 8자 이상 및 이메일 포함 여부)
  void validateForm({
    required String name, required String phone, required String email,
    required String id, required String password,
    required String zipcode, required String address,
    String? car, String? carNum,
  }) {
    // 백엔드 엔티티 제약조건(Email Not Null 등) 및 8자 이상 양식 체크
    bool isIdValid = id.length >= 8;
    bool isPwValid = password.length >= 8;

    bool commonValid = name.isNotEmpty && phone.isNotEmpty && email.isNotEmpty &&
        isIdValid && isPwValid && zipcode.isNotEmpty && address.isNotEmpty;

    if (state.selectedRole == UserRole.driver) {
      // 차주는 차량 명칭과 번호까지 확인
      state = state.copyWith(isFormValid: commonValid && car!.isNotEmpty && carNum!.isNotEmpty);
    } else {
      state = state.copyWith(isFormValid: commonValid);
    }
  }

  // 2. 서버 가입 요청 (성공 시 null, 실패 시 서버의 에러 메시지 반환)
  Future<String?> registerUser(Map<String, dynamic> userData) async {
    final endpoint = state.selectedRole == UserRole.shipper ? "shipper" : "carrier";
    final url = "http://10.0.2.2:8080/api/auth/signup/$endpoint";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return null; // 성공
      } else {
        // 서버(AuthService.java)에서 throw한 에러 메시지 반환
        // 예: "이미 존재하는 아이디입니다."
        return response.body;
      }
    } catch (e) {
      return "서버와 통신하는 중 오류가 발생했습니다.";
    }
  }
}

final signupViewModelProvider = StateNotifierProvider<SignupViewModel, SignupState>((ref) => SignupViewModel());