import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shipper/favorite_address_model.dart';
import '../../services/shipper/address_local_service.dart';

class FavoriteAddressState {
  final List<FavoriteAddressModel> addresses;
  final bool isLoading;

  FavoriteAddressState({
    this.addresses = const [],
    this.isLoading = false,
  });

  FavoriteAddressState copyWith({
    List<FavoriteAddressModel>? addresses,
    bool? isLoading,
  }) {
    return FavoriteAddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoriteAddressNotifier extends StateNotifier<FavoriteAddressState> {
  final AddressLocalService _service;

  FavoriteAddressNotifier(this._service) : super(FavoriteAddressState()) {
    loadAddresses();
  }

  // 주소 목록 불러오기
  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true);
    final addresses = await _service.getFavoriteAddresses();
    state = state.copyWith(addresses: addresses, isLoading: false);
  }

  // 주소 추가하기
  Future<void> addAddress(String alias, String address, String detailAddress) async {
    final newAddress = FavoriteAddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      alias: alias,
      address: address,
      detailAddress: detailAddress,
    );
    
    final updatedList = [...state.addresses, newAddress];
    await _service.saveFavoriteAddresses(updatedList);
    state = state.copyWith(addresses: updatedList);
  }

  // 주소 삭제하기
  Future<void> removeAddress(String id) async {
    final updatedList = state.addresses.where((a) => a.id != id).toList();
    await _service.saveFavoriteAddresses(updatedList);
    state = state.copyWith(addresses: updatedList);
  }
}

final addressLocalServiceProvider = Provider((ref) => AddressLocalService());

final favoriteAddressViewModelProvider = StateNotifierProvider<FavoriteAddressNotifier, FavoriteAddressState>((ref) {
  final service = ref.watch(addressLocalServiceProvider);
  return FavoriteAddressNotifier(service);
});
