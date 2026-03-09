import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportButton extends StatelessWidget {
  final int orderId;
  final double? width;
  final double? height;

  const ReportButton({
    super.key,
    required this.orderId,
    this.width,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => context.push('/report-create', extra: orderId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text(
          "신고하기",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
