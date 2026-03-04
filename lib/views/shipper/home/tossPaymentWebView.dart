import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/config/tossPaymentsConfig.dart';

class TossPaymentWebView extends StatefulWidget {
  final String orderId;
  final String orderName;
  final int amount;

  const TossPaymentWebView({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
  });

  @override
  State<TossPaymentWebView> createState() => _TossPaymentWebViewState();
}

class _TossPaymentWebViewState extends State<TossPaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // 결제 성공 URL 감지
            if (request.url.contains(TossPaymentConfig.successUrl)) {
              final uri = Uri.parse(request.url);
              final paymentKey = uri.queryParameters['paymentKey'];
              final orderId = uri.queryParameters['orderId'];
              final amount = uri.queryParameters['amount'];

              // 결과값을 가지고 이전 화면으로 복귀
              Navigator.pop(context, {
                "paymentKey": paymentKey,
                "orderId": orderId,
                "amount": amount,
              });
              return NavigationDecision.prevent;
            }
            // 결제 실패 URL 감지
            if (request.url.contains(TossPaymentConfig.failUrl)) {
              Navigator.pop(context, null); // 실패 시 null 반환
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildTossHtml()); // HTML 직접 로드
  }

  // 토스페이먼츠 SDK를 실행할 최소한의 HTML
  String _buildTossHtml() {
    return """
    <!DOCTYPE html>
    <html>
      <head>
        <script src="https://js.tosspayments.com/v1/payment"></script>
      </head>
      <body>
        <script>
          var tossPayments = TossPayments("${TossPaymentConfig.clientKey}");
          tossPayments.requestPayment('가상계좌', {
            amount: ${widget.amount},
            orderId: '${widget.orderId}',
            orderName: '${widget.orderName}',
            successUrl: '${TossPaymentConfig.successUrl}',
            failUrl: '${TossPaymentConfig.failUrl}',
          });
        </script>
      </body>
    </html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("토스 결제")),
      body: WebViewWidget(controller: _controller),
    );
  }
}