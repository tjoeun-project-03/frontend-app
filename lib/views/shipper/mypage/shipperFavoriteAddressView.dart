import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../viewmodels/shipper/favorite_address_vm.dart';
import '../../../widgets/common/bottomNavBar.dart';

class ShipperFavoriteAddressView extends ConsumerStatefulWidget {
  const ShipperFavoriteAddressView({super.key});

  @override
  ConsumerState<ShipperFavoriteAddressView> createState() => _ShipperFavoriteAddressViewState();
}

class _ShipperFavoriteAddressViewState extends ConsumerState<ShipperFavoriteAddressView> {
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _aliasController.dispose();
    _addressController.dispose();
    _detailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Tmap 주소 검색 로직 (ShipperHomeView 로직 활용)
  Future<void> _searchAddress(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final String tmapApiKey = (dotenv.env['TMAP_API_KEY'] ?? "").trim();
    final url = "https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=${Uri.encodeComponent(keyword)}&resCoordType=WGS84GEO&count=10";

    try {
      final response = await Dio().get(url, options: Options(headers: {"appKey": tmapApiKey}));
      if (response.statusCode == 200 && response.data['searchPoiInfo'] != null) {
        setState(() {
          _searchResults = response.data['searchPoiInfo']['pois']['poi'];
        });
      }
    } catch (e) {
      debugPrint("주소 검색 에러: $e");
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchAddress(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color bgGrey = Color(0xFFF8F9FA);
    
    final addressState = ref.watch(favoriteAddressViewModelProvider);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "자주 쓰는 주소",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: addressState.isLoading
          ? const Center(child: CircularProgressIndicator(color: jimlineNavy))
          : addressState.addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: addressState.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressState.addresses[index];
                    return _buildAddressCard(address);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(),
        backgroundColor: jimlineNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("주소 추가", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: JimlineBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pop();
          } else {
            context.go('/shipper-home');
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "등록된 주소가 없습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddAddressSheet(),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text("첫 주소 등록하기", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2B88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(dynamic address) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.alias, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2B88))),
                const SizedBox(height: 8),
                Text(address.address, style: const TextStyle(fontSize: 14, color: Color(0xFF444444))),
                if (address.detailAddress.isNotEmpty)
                  Text(address.detailAddress, style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDelete(address.id),
          ),
        ],
      ),
    );
  }

  // 주소 등록 바텀 시트 (검색 기능 포함)
  void _showAddAddressSheet() {
    _aliasController.clear();
    _addressController.clear();
    _detailController.clear();
    _searchResults = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("주소 추가", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _aliasController,
                  decoration: const InputDecoration(labelText: "주소 별명 (예: 우리집, 회사)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  onChanged: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () async {
                      if (val.isEmpty) {
                        setSheetState(() => _searchResults = []);
                        return;
                      }
                      final String tmapApiKey = (dotenv.env['TMAP_API_KEY'] ?? "").trim();
                      final url = "https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=${Uri.encodeComponent(val)}&resCoordType=WGS84GEO&count=10";
                      try {
                        final response = await Dio().get(url, options: Options(headers: {"appKey": tmapApiKey}));
                        if (response.statusCode == 200 && response.data['searchPoiInfo'] != null) {
                          setSheetState(() {
                            _searchResults = response.data['searchPoiInfo']['pois']['poi'];
                          });
                        }
                      } catch (e) { debugPrint(e.toString()); }
                    });
                  },
                  decoration: const InputDecoration(labelText: "주소 검색", hintText: "도로명 또는 지번 주소 입력", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final poi = _searchResults[index];
                        return ListTile(
                          title: Text(poi['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text("${poi['upperAddrName']} ${poi['middleAddrName']} ${poi['lowerAddrName']}", style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            setSheetState(() {
                              _addressController.text = poi['name'];
                              _searchResults = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _detailController,
                  decoration: const InputDecoration(labelText: "상세 주소 (선택)", border: OutlineInputBorder()),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_aliasController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                        await ref.read(favoriteAddressViewModelProvider.notifier).addAddress(
                          _aliasController.text,
                          _addressController.text,
                          _detailController.text,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2B88), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("주소 저장하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("주소 삭제"),
        content: const Text("이 주소를 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              await ref.read(favoriteAddressViewModelProvider.notifier).removeAddress(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("삭제", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
