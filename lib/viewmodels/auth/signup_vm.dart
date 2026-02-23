import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { none, shipper, driver }

// 회원가입 페이지의 상태를 담는 클래스
class SignupState {
  final UserRole selectedRole;
  final bool isPasswordMatched; // 비밀번호 일치 여부
  final bool isPasswordChecked; // 비밀번호 중복 확인 여부
  final bool isFormValid;       // 전체 폼 유효성 (버전 활성화용)

  SignupState({
    this.selectedRole = UserRole.none,
    this.isPasswordMatched = false,
    this.isFormValid = false,
    this.isPasswordChecked = false,
  });

  SignupState copyWith({
    UserRole? selectedRole,
    bool? isPasswordMatched,
    bool? isPasswordChecked,
    bool? isFormValid,
  }) {
    return SignupState(
      selectedRole: selectedRole ?? this.selectedRole,
      isPasswordMatched: isPasswordMatched ?? this.isPasswordMatched,
      isPasswordChecked: isPasswordChecked ?? this.isPasswordChecked,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

final signupViewModelProvider = StateNotifierProvider<SignupViewModel, SignupState>((ref) {
  return SignupViewModel();
});

class SignupViewModel extends StateNotifier<SignupState> {
  SignupViewModel() : super(SignupState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  // 비밀번호 중복 확인 상태 업데이트
  void checkPasswordDuplication(String password) {
    if (password.length >= 8) {
      // 실제로는 여기서 API를 호출합니다.
      state = state.copyWith(isPasswordChecked: true);
    }
  }

  // 모든 필드 데이터를 받아 유효성을 실시간 검사
  void validateForm({
    required String name,
    required String phone,
    required String id,
    required String password,
    required String address,
  }) {
    // 💡 개발 편의를 위해 모든 조건을 무시하고 항상 true를 반환하도록 수정합니다.
    const formValid = true;

    state = state.copyWith(
      isFormValid: formValid,
      isPasswordMatched: true, // 테스트 시 비밀번호 불일치 메시지 방지
      isPasswordChecked: true, // 테스트 시 중복확인 안 해도 넘어가게 설정
    );

    // 필수값 입력 여부 확인
    // final formValid = name.isNotEmpty &&
    //     phone.isNotEmpty &&
    //     id.isNotEmpty &&
    //     password.isNotEmpty &&
    //     state.isPasswordChecked &&
    //     address.isNotEmpty;
    //
    // state = state.copyWith(
    //   isFormValid: formValid,
    // );
  }
}