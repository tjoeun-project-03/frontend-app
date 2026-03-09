import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/common/api_service.dart';
import 'login_vm.dart';

enum UserRole { shipper, driver }

class SignupState {
  final UserRole? selectedRole; // 🚀 초기값을 null로 변경
  final bool isFormValid;
  final String carType;
  final int freezer;

  SignupState({this.selectedRole, this.isFormValid = false, this.carType = '1T', this.freezer = 0});

  SignupState copyWith({UserRole? selectedRole, bool? isFormValid, String? carType, int? freezer}) {
    return SignupState(
      selectedRole: selectedRole ?? this.selectedRole,
      isFormValid: isFormValid ?? this.isFormValid,
      carType: carType ?? this.carType,
      freezer: freezer ?? this.freezer,
    );
  }
}

class SignupViewModel extends StateNotifier<SignupState> {
  final ApiService _api = ApiService();
  final Ref _ref;

  SignupViewModel(this._ref) : super(SignupState());

  void selectRole(UserRole role) => state = state.copyWith(selectedRole: role);
  void toggleFreezer(bool val) => state = state.copyWith(freezer: val ? 1 : 0);
  void updateCarType(String val) => state = state.copyWith(carType: val);

  void validateForm({ String? name, String? phone, String? email, String? id, String? password, String? zipcode, String? address, String? car, String? carNum,}) {
    bool isValid = (name?.isNotEmpty ?? false) && 
                   (phone?.isNotEmpty ?? false) && 
                   (email?.isNotEmpty ?? false) && 
                   (id?.isNotEmpty ?? false) && 
                   (password != null && password.length >= 8) && 
                   (zipcode?.isNotEmpty ?? false) && 
                   (address?.isNotEmpty ?? false);
                   
    if (state.selectedRole == UserRole.driver) {
      isValid = isValid && (car?.isNotEmpty ?? false) && (carNum?.isNotEmpty ?? false);
    }
    state = state.copyWith(isFormValid: isValid);
  }

  Future<String?> registerUser(Map<String, dynamic> userData, {bool autoLogin = false}) async {
    final String endpoint = state.selectedRole == UserRole.driver ? '/api/auth/signup/carrier' : '/api/auth/signup/shipper';
    try {
      await _api.dio.post(endpoint, data: userData);
      
      if (autoLogin) {
        print("✅ 회원가입 성공! 자동 로그인을 시도합니다...");
        // 🚀 login 메서드는 String?(role)을 반환하므로 null 여부로 성공 판단
        final String? role = await _ref.read(loginViewModelProvider.notifier).login(
          userData['userId'], 
          userData['userPw'],
        );
        return role != null ? null : "자동 로그인에 실패했습니다.";
      }

      return null;
    } on DioException catch (e) {
      return e.response?.data['message'] ?? "회원가입 중 오류가 발생했습니다.";
    } catch (e) {
      return "알 수 없는 오류가 발생했습니다.";
    }
  }
}

final signupViewModelProvider = StateNotifierProvider<SignupViewModel, SignupState>((ref) {
  return SignupViewModel(ref);
});
