import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../models/carrier/order_model.dart';
import '../../../viewmodels/carrier/available_order_vm.dart';
import '../../../viewmodels/carrier/active_order_vm.dart';

class OrderDetailView extends ConsumerStatefulWidget {
  final OrderResponse order;
  const OrderDetailView({super.key, required this.order});

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  late final WebViewController _mapController;
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  void initState() {
    super.initState();
    _initMapController();
  }

  void _initMapController() {
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadHtmlString(_buildTmapHtml());
  }

  String _buildTmapHtml() {
    final sLat = widget.order.startLat ?? 37.5665;
    final sLng = widget.order.startLng ?? 126.9780;
    final eLat = widget.order.endLat ?? 37.5665;
    final eLng = widget.order.endLng ?? 126.9780;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&appKey=zevdfBBPeu3eQZItbMK1k812led3px8x2dr5r9sZ"></script>
  <style>
    body, html, #map_div { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #FFFFFF; }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("오더 상세 정보", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: WebViewWidget(controller: _mapController),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddressSection(),
                        const Divider(height: 40),
                        _buildDetailRow("품목", widget.order.content),
                        _buildDetailRow("차량", widget.order.carType),
                        _buildDetailRow("거리", "${widget.order.distance.toStringAsFixed(1)}km"),
                        _buildDetailRow("예상 소요시간", "${widget.order.duration}분"),
                        const SizedBox(height: 20),
                        const Text("운송료", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("${NumberFormat('#,###').format(widget.order.price)}원",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryNavy)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("이 오더 수락하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.order.departure, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        Container(
          height: 30,
          margin: const EdgeInsets.only(left: 4),
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.grey, width: 1))),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, size: 12, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.order.arrival, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> _handleAccept() async {
    final success = await ref.read(availableOrderProvider.notifier).acceptOrder(widget.order.orderId);
    if (success && mounted) {
      ref.read(activeOrderProvider.notifier).setActiveOrder(widget.order);
      context.go('/carrier-home');
    }
  }
}
