import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _truckIconBase64;

  static const Color jimlineNavy = Color(0xFF1A2B88);
  static const Color borderGrey = Color(0xFFEEEEEE);
  static const Color textGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadTruckIcon();
    _initMapController();
    Future.microtask(() {
      ref.read(trackingProvider.notifier).fetchOrderTimeline(widget.orderId);
    });
  }

  // 🚀 로컬 에셋 이미지를 Base64로 변환
  Future<void> _loadTruckIcon() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/images/truck_logo.png');
      final Uint8List list = bytes.buffer.asUint8List();
      setState(() {
        _truckIconBase64 = 'data:image/png;base64,${base64Encode(list)}';
      });
    } catch (e) {
      debugPrint("트럭 아이콘 로드 실패: $e");
    }
  }

  void _initMapController() {
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F5F5));
  }

  void _loadMapHtml(TrackingModel data) {
    if (_truckIconBase64 == null) {
      // 아이콘 로딩이 늦어질 경우 잠시 대기 후 재시도
      Future.delayed(const Duration(milliseconds: 100), () => _loadMapHtml(data));
      return;
    }
    _mapController.loadHtmlString(_buildTmapHtml(data));
    setState(() {
      _isFirstLoad = false;
    });
  }

  String _buildTmapHtml(TrackingModel data) {
    final sLat = data.startLat ?? 37.5665;
    final sLng = data.startLng ?? 126.9780;
    final eLat = data.endLat ?? 37.5665;
    final eLng = data.endLng ?? 126.9780;
    final dLat = data.lat;
    final dLng = data.lng;

    return '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&appKey=zevdfBBPeu3eQZItbMK1k812led3px8x2dr5r9sZ"></script>
    <style>
      body, html, #map_div { margin: 0; padding: 0; width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <div id="map_div"></div>
    <script>
      var map;
      var driverMarker;

      function initMap() {
        map = new Tmapv2.Map("map_div", {
          center: new Tmapv2.LatLng($dLat, $dLng),
          width: "100%",
          height: "100%",
          zoom: 14
        });
        
        new Tmapv2.Marker({
          position: new Tmapv2.LatLng($sLat, $sLng),
          icon: "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_b_m_s.png",
          map: map
        });

        new Tmapv2.Marker({
          position: new Tmapv2.LatLng($eLat, $eLng),
          icon: "http://tmapapi.sktelecom.com/upload/tmap/marker/pin_r_m_e.png",
          map: map
        });

        // 🚀 Base64 형태의 로컬 트럭 아이콘 적용
        driverMarker = new Tmapv2.Marker({
          position: new Tmapv2.LatLng($dLat, $dLng),
          icon: "$_truckIconBase64", 
          iconSize: new Tmapv2.Size(48, 48),
          map: map,
          title: "기사 위치"
        });

        var bounds = new Tmapv2.LatLngBounds();
        bounds.extend(new Tmapv2.LatLng($sLat, $sLng));
        bounds.extend(new Tmapv2.LatLng($eLat, $eLng));
        bounds.extend(new Tmapv2.LatLng($dLat, $dLng));
        map.fitBounds(bounds);
      }

      function updateDriverPosition(lat, lng) {
        if (driverMarker) {
          driverMarker.setPosition(new Tmapv2.LatLng(lat, lng));
        }
      }

      window.onload = function() {
        var check = setInterval(function() {
          if (typeof Tmapv2 !== 'undefined') {
            initMap();
            clearInterval(check);
          }
        }, 100);
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

    ref.listen(trackingProvider, (previous, next) {
      if (next.data != null) {
        if (_isFirstLoad) {
          _loadMapHtml(next.data!);
        } else if (previous?.data?.lat != next.data?.lat || previous?.data?.lng != next.data?.lng) {
          _updateDriverMarker(next.data!.lat, next.data!.lng);
        }
      }
    });

    if (state.isLoading || state.data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: jimlineNavy)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("배송 상세 추적", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.35, width: double.infinity, child: WebViewWidget(controller: _mapController)),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDriverSection(state.data!),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1, thickness: 1, color: borderGrey)),
                      _buildTimelineSection(state.data!.timelines),
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
        const CircleAvatar(radius: 26, backgroundColor: Color(0xFFF0F2FF), child: Icon(Icons.person, color: jimlineNavy, size: 30)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.driverName ?? "기사 배정 중", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            Text("${data.carInfo ?? '차량정보 없음'}", style: const TextStyle(fontSize: 13, color: textGrey)),
          ]),
        ),
        Container(decoration: BoxDecoration(color: const Color(0xFFF0F2FF), borderRadius: BorderRadius.circular(12)), child: IconButton(onPressed: () {}, icon: const Icon(Icons.phone_enabled, color: jimlineNavy))),
      ],
    );
  }

  Widget _buildTimelineSection(List<TimelineItemData> timelines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("운송 타임라인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 24),
        if (timelines.isEmpty) const Center(child: Text("기록된 타임라인이 없습니다."))
        else for (int i = 0; i < timelines.length; i++) _buildTimelineItem(timelines[i], isLast: i == timelines.length - 1),
      ],
    );
  }

  Widget _buildTimelineItem(TimelineItemData item, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(width: 24, height: 24, decoration: BoxDecoration(color: item.isDone ? jimlineNavy : Colors.white, shape: BoxShape.circle, border: Border.all(color: item.isDone ? jimlineNavy : borderGrey, width: 2)), child: item.isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
          if (!isLast) Container(width: 2, height: 40, color: item.isDone ? jimlineNavy : borderGrey),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: item.isDone ? Colors.black : textGrey)),
          const SizedBox(height: 4),
          Text(item.time ?? "", style: const TextStyle(fontSize: 12, color: textGrey)),
          const SizedBox(height: 20),
        ])),
      ],
    );
  }
}
