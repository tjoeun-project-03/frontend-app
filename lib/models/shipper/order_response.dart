import 'dart:ffi';

class OrderResponse {
  final int? orderId;
  final String? departure;
  final String? arrival;
  final String? carrier;
  final String? currentStatus; // "CREATED", "ACCEPTED" 등
  final DateTime? created;
  final String? invoiceNo;

  OrderResponse({this.orderId, this.departure, this.arrival, this.carrier, this.currentStatus, this.created, this.invoiceNo});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'],
      departure: json['departure'],
      arrival: json['arrival'],
      carrier: json['carrierName'],
      currentStatus: json['status'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      invoiceNo: json['invoiceNo'],
    );
  }
}