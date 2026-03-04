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
  bool _isFirstLoad = true;

  static const Color jimlineNavy = Color(0xFF1A2B88);
  static const Color borderGrey = Color(0xFFEEEEEE);
  static const Color textGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _initMapController();
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
            debugPrint("Tmap 페이지 로드 완료");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView 에러: ${error.description}");
          },
        ),
      );
  }

  // 지도를 처음 그리거나 전체 갱신할 때 사용
  void _loadMapHtml(TrackingModel data) {
    debugPrint("지도 HTML 로드 시작");
    _mapController.loadHtmlString(_buildTmapHtml(data));
    setState(() {
      _isFirstLoad = false;
    });
  }

  String _buildTmapHtml(TrackingModel data) {
    final startLat = data.startLat ?? 37.5665;
    final startLng = data.startLng ?? 126.9780;
    final endLat = data.endLat ?? 37.5665;
    final endLng = data.endLng ?? 126.9780;
    final driverLat = data.lat;
    final driverLng = data.lng;

    return '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&appKey=zevdfBBPeu3eQZItbMK1k812led3px8x2dr5r9sZ"></script>
    <style>
      body, html, #map_div { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #F5F5F5; }
    </style>
  </head>
  <body>
    <div id="map_div"></div>
    <script>
      var map;
      var driverMarker;
      var startMarker;
      var endMarker;

      function initMap() {
        try {
          map = new Tmapv2.Map("map_div", {
            center: new Tmapv2.LatLng($driverLat, $driverLng),
            width: "100%",
            height: "100%",
            zoom: 14
          });
          
          startMarker = new Tmapv2.Marker({
            position: new Tmapv2.LatLng($startLat, $startLng),
            icon: "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_s.png",
            map: map,
            title: "출발지"
          });

          endMarker = new Tmapv2.Marker({
            position: new Tmapv2.LatLng($endLat, $endLng),
            icon: "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_e.png",
            map: map,
            title: "도착지"
          });

          driverMarker = new Tmapv2.Marker({
            position: new Tmapv2.LatLng($driverLat, $driverLng),
            icon: "https://cdn-icons-png.flaticon.com/512/3063/3063822.png",
            iconSize: new Tmapv2.Size(34, 34),
            map: map,
            title: "기사 위치"
          });

          var bounds = new Tmapv2.LatLngBounds();
          bounds.extend(new Tmapv2.LatLng($startLat, $startLng));
          bounds.extend(new Tmapv2.LatLng($endLat, $endLng));
          bounds.extend(new Tmapv2.LatLng($driverLat, $driverLng));
          map.fitBounds(bounds);
        } catch (e) {
          console.error("Tmap 초기화 에러: ", e);
        }
      }

      function updateDriverPosition(lat, lng) {
        if (driverMarker) {
          var newPos = new Tmapv2.LatLng(lat, lng);
          driverMarker.setPosition(newPos);
        }
      }

      window.onload = function() {
        if (typeof Tmapv2 !== 'undefined') {
          initMap();
        } else {
          var checkExist = setInterval(function() {
            if (typeof Tmapv2 !== 'undefined') {
              initMap();
              clearInterval(checkExist);
            }
          }, 100);
        }
      };
    </script>
  </body>
  </html>
  ''';
  }

  void _updateDriverMarker(double lat, double lng) {
    _mapController.runJavaScript('if(typeof updateDriverPosition === "function") updateDriverPosition($lat, $lng);');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);

    // 데이터 변화 감지
    ref.listen(trackingProvider, (previous, next) {
      if (next.data != null) {
        // 1. 처음 데이터 로드 시 지도 생성
        if (_isFirstLoad) {
          _loadMapHtml(next.data!);
        } 
        // 2. 이후 좌표 변경 시 마커만 업데이트
        else if (previous?.data?.lat != next.data?.lat || previous?.data?.lng != next.data?.lng) {
          _updateDriverMarker(next.data!.lat, next.data!.lng);
        }
      }
    });

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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: WebViewWidget(controller: _mapController),
          ),
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
                      _buildDriverSection(data),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1, thickness: 1, color: borderGrey),
                      ),
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {}, 
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
