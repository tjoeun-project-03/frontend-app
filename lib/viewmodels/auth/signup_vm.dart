import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

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

  final _api = ApiService();

  void selectRole(UserRole role) => state = state.copyWith(selectedRole: role);
  void updateCarType(String type) => state = state.copyWith(carType: type);
  void toggleFreezer(bool isFreezer) => state = state.copyWith(freezer: isFreezer ? 1 : 0);

  void validateForm({
    required String name, required String phone, required String email,
    required String id, required String password,
    required String zipcode, required String address,
    String? car, String? carNum,
  }) {
    bool isIdValid = id.length >= 8;
    bool isPwValid = password.length >= 8;

    bool commonValid = name.isNotEmpty && phone.isNotEmpty && email.isNotEmpty &&
        isIdValid && isPwValid && zipcode.isNotEmpty && address.isNotEmpty;

    if (state.selectedRole == UserRole.driver) {
      state = state.copyWith(isFormValid: commonValid && car!.isNotEmpty && carNum!.isNotEmpty);
    } else {
      state = state.copyWith(isFormValid: commonValid);
    }
  }

  Future<String?> registerUser(Map<String, dynamic> userData) async {
    final endpoint = state.selectedRole == UserRole.shipper ? "shipper" : "carrier";

    try {
      final response = await _api.dio.post(
        "/api/auth/signup/$endpoint",
        data: userData,
      );

      if (response.statusCode == 200) {
        return null; // 성공
      } else {
        return response.data.toString();
      }
    } catch (e) {
      return "서버와 통신하는 중 오류가 발생했습니다.";
    }
  }
}

final signupViewModelProvider = StateNotifierProvider<SignupViewModel, SignupState>((ref) => SignupViewModel());