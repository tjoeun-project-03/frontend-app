import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'shipperPaymentView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'; // 🚀 제스처 인식을 위해 필수
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShipperHomeView extends StatefulWidget {
  const ShipperHomeView({super.key});
  @override
  State<ShipperHomeView> createState() => _ShipperHomeViewState();
}

class _ShipperHomeViewState extends State<ShipperHomeView> {
  late final WebViewController _mapController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadFlutterAsset('assets/tmap.html');

  Timer? _debounce;
  double _estimatedWeight = 11.0;
  String? _selectedCategory = "가전";
  int _serverPrice = 0;
  bool _isCalculating = false;

  double _distance = 0.0;
  int _duration = 0;
  bool _isNight = false;

  double? startLat, startLng, endLat, endLng;
  List<dynamic> _searchResults = [];
  String _activeSearchType = '';

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final Color jimlineNavy = const Color(0xFF1A2B88);

  void _onSearchChanged(String val, String type) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (val.isNotEmpty)
        _searchAddress(val, type);
      else
        setState(() => _searchResults = []);
    });
  }

  Future<void> _searchAddress(String keyword, String type) async {
    final String tmapApiKey = (dotenv.env['TMAP_API_KEY'] ?? "").trim();
    final url = Uri.parse(
        "https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=${Uri
            .encodeComponent(keyword)}&resCoordType=WGS84GEO&count=10");

    try {
      final response = await http.get(url, headers: {"appKey": tmapApiKey});
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['searchPoiInfo'] != null) {
          setState(() {
            _searchResults = res['searchPoiInfo']['pois']['poi'];
            _activeSearchType = type;
          });
        }
      }
    } catch (e) {
      debugPrint("통신 에러: $e");
    }
  }

  void _selectAddress(dynamic poi) {
    double lat = double.parse(poi['frontLat']);
    double lon = double.parse(poi['frontLon']);
    final String tmapApiKey = (dotenv.env['TMAP_API_KEY'] ?? "").trim();

    setState(() {
      if (_activeSearchType == 'start') {
        startLat = lat;
        startLng = lon;
        _startController.text = poi['name'];
      } else {
        endLat = lat;
        endLng = lon;
        _endController.text = poi['name'];
      }
      _searchResults = [];
    });

    _mapController.runJavaScript("setMarker($lat, $lon, '$_activeSearchType')");

    if (startLat != null && endLat != null) {
      _mapController.runJavaScript(
          "drawRoute($startLat, $startLng, $endLat, $endLng, '$tmapApiKey')");
    }
  }

  Future<void> _fetchEstimate() async {
    if (startLat == null || endLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("출발지와 도착지를 검색해주세요.")));
      return;
    }
    setState(() => _isCalculating = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/v1/orders/estimate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "start_lat": startLat, "start_lng": startLng,
          "end_lat": endLat, "end_lng": endLng,
          "car_type": _mapWeightToCarType(_estimatedWeight),
          "content": _selectedCategory,
        }),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success']) {
          setState(() {
            _serverPrice = res['data']['total_cost'];
            _distance = res['data']['distance_km'].toDouble();
            _duration = res['data']['duration_min'];
            _isNight = res['data']['is_night'];
          });
        }
      }
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ]),
                child: Column(
                  children: [
                    _buildSearchField(
                        Icons.search, Colors.blue, "출발지 검색", _startController, (
                        val) => _onSearchChanged(val, 'start')),
                    const Divider(height: 24),
                    _buildSearchField(
                        Icons.place, Colors.red, "도착지 검색", _endController, (
                        val) => _onSearchChanged(val, 'end')),
                    if (_searchResults.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8)),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final poi = _searchResults[index];
                            return ListTile(
                              title: Text(poi['name'], style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(
                                  "${poi['upperAddrName']} ${poi['middleAddrName']}",
                                  style: const TextStyle(fontSize: 12)),
                              onTap: () => _selectAddress(poi),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 🚀 지도 컨테이너
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: WebViewWidget(
                  controller: _mapController,
                  // 🚀 중요: 지도 조작 시 스크롤뷰와 충돌 방지
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(() =>
                        EagerGestureRecognizer()),
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryList(),
            _buildWeightSlider(),
            _buildEstimateButton(),
            // 🚀 파이썬 서버 데이터 결과 섹션
            if (_serverPrice > 0) _buildEstimateDetail(),
            _buildPriceSection(),
            _buildOrderButton(),
          ],
        ),
      ),
    );
  }

  // 🚀 상세 견적 정보 위젯
  Widget _buildEstimateDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _detailRow("예상 이동 거리", "${_distance.toStringAsFixed(1)} km"),
            _detailRow("예상 소요 시간", "$_duration 분"),
            _detailRow("야간 할증", _isNight ? "적용됨" : "미적용"),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
              ]));

  Widget _buildSearchField(IconData icon, Color color, String hint,
      TextEditingController ctrl, Function(String) onChg) =>
      Row(children: [Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: TextField(controller: ctrl,
            onChanged: onChg,
            decoration: InputDecoration(
                hintText: hint, border: InputBorder.none)
        ))
      ]);

  Widget _buildCategoryList() {
    final categories = ["박스/잡화", "가구", "가전", "냉장/냉동", "기타"];
    return SizedBox(height: 45,
        child: ListView.builder(scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedCategory == categories[index];
              return GestureDetector(onTap: () =>
                  setState(() => _selectedCategory = categories[index]),
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                          color: isSelected ? jimlineNavy : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: isSelected ? jimlineNavy : Colors
                                  .grey[200]!)),
                      child: Center(child: Text(categories[index],
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors
                                  .black)))));
            }));
  }

  Widget _buildWeightSlider() =>
      Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
              children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("예상 무게", style: TextStyle(
                        fontWeight: FontWeight.bold, color: jimlineNavy)),
                    Text("${_estimatedWeight.toStringAsFixed(1)} 톤",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: jimlineNavy))
                  ]),
                Slider(value: _estimatedWeight,
                    min: 0.5,
                    max: 25.0,
                    activeColor: jimlineNavy,
                    onChanged: (val) => setState(() => _estimatedWeight = val))
              ]));

  Widget _buildEstimateButton() =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                  onPressed: _isCalculating ? null : _fetchEstimate,
                  icon: _isCalculating
                      ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.calculate_outlined),
                  label: Text(_isCalculating ? "계산 중..." : "견적 확인하기",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(foregroundColor: jimlineNavy,
                      side: BorderSide(color: jimlineNavy, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))))));

  Widget _buildPriceSection() =>
      Padding(padding: const EdgeInsets.all(16),
          child: Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("최종 예상 견적",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${_serverPrice.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (
                        m) => '${m[1]},')}원", style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: jimlineNavy))
                  ])));

  Widget _buildOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            // 🚀 견적 가격이 있을 때만 결제 페이지로 이동
            if (_serverPrice > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShipperPaymentView(
                        weight: _estimatedWeight,
                        price: _serverPrice,
                        startAddress: _startController.text,
                        // 출발지 전달
                        endAddress: _endController.text,
                        // 도착지 전달
                        category: _selectedCategory ?? "기타", // 화물 종류 전달
                      ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("먼저 견적 확인을 완료해주세요.")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: jimlineNavy,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("운송 예약하기", style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
  String _mapWeightToCarType(double weight) {
    if (weight <= 1.0) return "1t";
    if (weight <= 5.0) return "5t";
    if (weight <= 11.0) return "11t";
    return "25t";
  }
}