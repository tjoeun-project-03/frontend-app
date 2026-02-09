import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. UserRole 정의 (이게 있어야 View에서 에러가 안 납니다)
enum UserRole { none, shipper, driver }

// 2. Provider 정의
final signupViewModelProvider = StateNotifierProvider<SignupViewModel, UserRole>((ref) {
  return SignupViewModel();
});

// 3. ViewModel 클래스
class SignupViewModel extends StateNotifier<UserRole> {
  SignupViewModel() : super(UserRole.none);

  void selectRole(UserRole role) {
    state = role;
  }
}