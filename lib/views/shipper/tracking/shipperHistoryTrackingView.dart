import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../viewmodels/shipper/tracking_vm.dart';
import '../../../models/shipper/tracking_model.dart';

class ShipperHistoryTrackingView extends ConsumerStatefulWidget {
  final int orderId;
  const ShipperHistoryTrackingView({super.key, required this.orderId});

  @override
  ConsumerState<ShipperHistoryTrackingView> createState() => _ShipperHistoryTrackingViewState();
}

class _ShipperHistoryTrackingViewState extends ConsumerState<ShipperHistoryTrackingView> {
  late final WebViewController _mapController;

  // 상수 컬러 정의
  static const Color jimlineNavy = Color(0xFF1A2B88);
  static const Color borderGrey = Color(0xFFEEEEEE);
  static const Color bgGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _initMapController();
    // 화면 진입 시 서버 데이터 호출
    Future.microtask(() {
      ref.read(trackingProvider.notifier).fetchOrderTimeline(widget.orderId);
    });
  }

  void _initMapController() {
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F5F5))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // 페이지 로딩 후 기사 위치로 마커 이동 및 중심 설정 함수 호출 가능
            _updateMarker(37.5665, 126.9780); // 예시 좌표 (서울시청)
          },
        ),
      )
    // 서버 페이지 대신 로컬 HTML 코드를 바로 로드합니다.
      ..loadHtmlString(_buildTmapHtml(37.5665, 126.9780));
  }

  // Tmap JS SDK를 구동하는 HTML 소스 생성
  String _buildTmapHtml(double lat, double lng) {
    return '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&appKey=zevdfBBPeu3eQZItbMK1k812led3px8x2dr5r9sZ"></script>
    <style>
      body, html, #map_div { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #F5F5F5; }
    </style>
  </head>
  <body>
    <div id="map_div"></div>
    <script>
      var map;
      var marker;

      // 2. 안전한 초기화 함수
      function checkAndInit() {
        if (typeof Tmapv2 !== 'undefined') {
          console.log("Tmapv2 로드 완료");
          initMap();
        } else {
          console.log("Tmapv2 로딩 중...");
          setTimeout(checkAndInit, 100); // 0.1초 뒤 다시 시도
        }
      }

      function initMap() {
        map = new Tmapv2.Map("map_div", {
          center: new Tmapv2.LatLng($lat, $lng),
          width: "100%",
          height: "100%",
          zoom: 16
        });
        
        marker = new Tmapv2.Marker({
          position: new Tmapv2.LatLng($lat, $lng),
          map: map
        });
      }

      window.onload = checkAndInit;
    </script>
  </body>
  </html>
  ''';
  }

  // Flutter에서 기사 위치가 바뀔 때 호출하는 함수
  void _updateMarker(double lat, double lng) {
    _mapController.runJavaScript('updatePosition($lat, $lng);');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);

    if (state.isLoading || state.data == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: jimlineNavy)),
      );
    }

    final data = state.data!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("배송 상세 추적",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. 상단 지도 영역 (화면의 약 35~40% 고정)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Stack(
              children: [
                WebViewWidget(controller: _mapController),
              ],
            ),
          ),

          // 2. 하단 상세 정보 및 타임라인 (나머지 영역 스크롤)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 기사 및 차량 정보 섹션
                      _buildDriverSection(data),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1, thickness: 1, color: borderGrey),
                      ),

                      // 운송 현황 타임라인 섹션
                      _buildTimelineSection(data.timelines),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 컴포넌트 분리 ---

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: jimlineNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDriverSection(TrackingModel data) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFF0F2FF),
          child: Icon(Icons.person, color: jimlineNavy, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.driverName ?? "기사 배정 중",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                "${data.carInfo ?? '차량정보 없음'}",
                style: const TextStyle(fontSize: 13, color: textGrey),
              ),
            ],
          ),
        ),
        // 전화 버튼
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {}, // TODO: 전화 걸기 연동
            icon: const Icon(Icons.phone_enabled, color: jimlineNavy),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(List<TimelineItemData> timelines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "운송 타임라인",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        if (timelines.isEmpty)
          const Center(child: Text("기록된 타임라인이 없습니다."))
        else
          for (int i = 0; i < timelines.length; i++)
            _buildTimelineItem(
              timelines[i],
              isLast: i == timelines.length - 1,
            ),
      ],
    );
  }

  Widget _buildTimelineItem(TimelineItemData item, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 선과 아이콘
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isDone ? jimlineNavy : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isDone ? jimlineNavy : borderGrey,
                  width: 2,
                ),
              ),
              child: item.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: item.isDone ? jimlineNavy : borderGrey,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // 텍스트 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: item.isDone ? Colors.black : textGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.time ?? "",
                style: const TextStyle(fontSize: 12, color: textGrey),
              ),
              const SizedBox(height: 20), // 항목 간 간격
            ],
          ),
        ),
      ],
    );
  }
}