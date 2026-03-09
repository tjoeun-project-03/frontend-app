import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../viewmodels/carrier/active_order_vm.dart';
import '../../../viewmodels/carrier/carrier_tracking_vm.dart';
import 'package:intl/intl.dart';

class CarrierTrackingView extends ConsumerStatefulWidget {
  const CarrierTrackingView({super.key});

  @override
  ConsumerState<CarrierTrackingView> createState() => _CarrierTrackingViewState();
}

class _CarrierTrackingViewState extends ConsumerState<CarrierTrackingView> {
  late final WebViewController _mapController;
  final Color primaryNavy = const Color(0xFF1A2B88);
  final TextEditingController _invoiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initMapController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeOrder = ref.read(activeOrderProvider).activeOrder;
      if (activeOrder != null) {
        ref.read(carrierTrackingProvider.notifier).startTracking(activeOrder.orderId);
      }
    });
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  void _initMapController() {
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeOrder = ref.read(activeOrderProvider).activeOrder;
      if (activeOrder != null) {
        _mapController.loadHtmlString(_buildTmapHtml(activeOrder));
      }
    });
  }

  String _buildTmapHtml(dynamic order) {
    final sLat = order.startLat ?? 37.5665;
    final sLng = order.startLng ?? 126.9780;
    final eLat = order.endLat ?? 37.5665;
    final eLng = order.endLng ?? 126.9780;

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
    function initMap() {
      try {
        map = new Tmapv2.Map("map_div", {
          center: new Tmapv2.LatLng($sLat, $sLng),
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

        setTimeout(function() {
          if (typeof Tmapv2.extension !== 'undefined' && Tmapv2.extension.TData) {
            drawCarRoute();
          } else {
            drawFallback();
          }
        }, 500);
      } catch (e) {
        console.error("Init Error: " + e.message);
      }
    }

    function drawCarRoute() {
      var tData = new Tmapv2.extension.TData();
      tData.getRoutePlanJson(
        new Tmapv2.LatLng($sLat, $sLng),
        new Tmapv2.LatLng($eLat, $eLng),
        { reqCoordType: "WGS84GEO", resCoordType: "WGS84GEO" },
        {
          onComplete: function(result) {
            var path = [];
            var features = result._responseData.features;
            for (var i in features) {
              if (features[i].geometry.type == "LineString") {
                for (var j in features[i].geometry.coordinates) {
                  var coord = features[i].geometry.coordinates[j];
                  path.push(new Tmapv2.LatLng(coord[1], coord[0]));
                }
              }
            }
            if (path.length > 0) {
              new Tmapv2.Polyline({ path: path, strokeColor: "#1A2B88", strokeWeight: 6, map: map });
              var bounds = new Tmapv2.LatLngBounds();
              path.forEach(function(p){ bounds.extend(p); });
              map.fitBounds(bounds);
            }
          },
          onError: function() { drawFallback(); }
        }
      );
    }

    function drawFallback() {
      var path = [new Tmapv2.LatLng($sLat, $sLng), new Tmapv2.LatLng($eLat, $eLng)];
      new Tmapv2.Polyline({ path: path, strokeColor: "#FF0000", strokeWeight: 4, strokeDashstyle: "dash", map: map });
      var bounds = new Tmapv2.LatLngBounds();
      path.forEach(function(p){ bounds.extend(p); });
      map.fitBounds(bounds);
    }

    window.onload = function() {
      var interval = setInterval(function() {
        if (typeof Tmapv2 !== 'undefined') {
          initMap();
          clearInterval(interval);
        }
      }, 100);
    };
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeOrderProvider);
    final activeOrder = activeState.activeOrder;

    if (activeOrder == null) {
      return const Scaffold(body: Center(child: Text("진행 중인 배차가 없습니다.")));
    }

    final String currentStatus = activeOrder.status.toUpperCase().trim();
    
    // 🚀 상태 판별: 상차 전인지, 운송 중인지 확인
    final bool isAccepted = currentStatus == 'ACCEPTED' || activeOrder.status == '배차 완료';
    final bool isTransiting = !isAccepted; // ACCEPTED가 아니면 (DEPARTED 등) 운송 중으로 간주

    String buttonText = "물품 상차 완료 (출발)";
    Color buttonColor = primaryNavy;
    VoidCallback onPressed = () => _showPickupDialog(activeOrder.orderId);

    if (isTransiting) {
      buttonText = "배송 완료 처리 (송장 입력)";
      buttonColor = Colors.green;
      onPressed = () => _showCompleteDialog(activeOrder);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(isTransiting ? "목적지로 이동 중" : "상차지로 이동 중", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildInfoCard(activeOrder),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: WebViewWidget(controller: _mapController),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickupDialog(int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("상차 완료 확인"),
        content: const Text("물품 상차를 완료하고 출발하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(activeOrderProvider.notifier).pickupOrder(orderId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("운행을 시작합니다!")));
              }
            },
            child: const Text("출발", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(dynamic order) {
    _invoiceController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("배송 최종 완료"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("고객으로부터 받은 송장번호를 입력해주세요."),
            const SizedBox(height: 16),
            TextField(
              controller: _invoiceController,
              decoration: InputDecoration(
                hintText: "송장번호 입력",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              final input = _invoiceController.text.trim();
              if (input != order.invoiceNo) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("송장번호가 일치하지 않습니다."), backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              final success = await ref.read(activeOrderProvider.notifier).completeOrder(order.orderId, input);
              if (success && mounted) {
                ref.read(carrierTrackingProvider.notifier).stopTracking();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("배송이 완료되었습니다!")));
              }
            },
            child: const Text("완료", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(order.departure, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          Container(
            height: 20,
            margin: const EdgeInsets.only(left: 4),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid)),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(order.arrival, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.content, style: const TextStyle(color: Colors.grey)),
              Text("${NumberFormat('#,###').format(order.price)}원", 
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
