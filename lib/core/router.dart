import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../views/auth/startView.dart';
import '../views/auth/loginView.dart';
import '../views/auth/roleSelectionView.dart';
import '../views/auth/signupView.dart';
import '../views/auth/licenseCameraView.dart';
import '../views/shipper/shipperNavControllerView.dart';
import '../views/shipper/home/shipperPaymentView.dart';
import '../views/shipper/tracking/shipperEvaluationView.dart';
import '../views/shipper/mypage/shipperNoticeView.dart';
import '../views/shipper/mypage/shipperInquiryView.dart';
import '../views/shipper/mypage/shipperReservationView.dart';
import '../views/shipper/mypage/shipperFavoriteAddressView.dart';
import '../views/shipper/mypage/shipperFaqView.dart';
import '../views/carrier/home/carrierHomeView.dart';
import '../views/carrier/home/orderDetailView.dart';
import '../views/shipper/tracking/shipper_order_list_view.dart';
import '../views/shipper/tracking/shipperHistoryTrackingView.dart';
import '../views/carrier/home/carrierRecommendationView.dart';
import '../models/carrier/order_model.dart';
import '../views/common/reportListView.dart';
import '../views/common/reportCreateView.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/role-selection', builder: (context, state) => const RoleSelectionView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
      GoRoute(
        path: '/license-camera',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return LicenseCameraView(signupData: data);
        },
      ),
      GoRoute(path: '/shipper-home', builder: (context, state) => const ShipperNavController()),
      GoRoute(path: '/carrier-home', builder: (context, state) => const CarrierHomeView()),
      GoRoute(
        path: '/carrier-order-detail',
        builder: (context, state) {
          final order = state.extra as OrderResponse;
          return OrderDetailView(order: order);
        },
      ),
      GoRoute(
        path: '/carrier-recommendation',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CarrierRecommendationView(
            currentLat: data['lat'] as double,
            currentLng: data['lng'] as double,
          );
        },
      ),
      // 메모: 내 신고 리스트 경로 추가
      GoRoute(
        path: '/report-list',
        builder: (context, state) => const ReportListView(),
      ),
      // 메모: 신고 작성 경로 추가
      GoRoute(
        path: '/report-create',
        builder: (context, state) {
          final orderId = state.extra as int;
          return ReportCreateView(orderId: orderId);
        },
      ),
      GoRoute(
          path: '/shipper-payment',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return ShipperPaymentView(
              weight: data['weight'] as double,
              price: data['price'] as int,
              startAddress: data['startAddress'] as String,
              endAddress: data['endAddress'] as String,
              category: data['category'] as String,
              distance: data['distance'] as double,
              duration: data['duration'] as int,
              startLat: data['startLat'] as String,
              startLng: data['startLng'] as String,
              endLat: data['endLat'] as String,
              endLng: data['endLng'] as String,
              surcharge: data['surcharge'] as int,
            );
          }
          ),
      GoRoute(path: '/evaluation', builder: (context, state) => const ShipperEvaluationView()),
      GoRoute(path: '/shipper-history', builder: (context, state) => const ShipperOrderListView()),
      GoRoute(
        path: '/shipper-tracking/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return ShipperHistoryTrackingView(orderId: orderId);
        },
      ),
      GoRoute(path: '/shipper-notice', builder: (context, state) => const ShipperNoticeView()),
      GoRoute(path: '/shipper-inquiry', builder: (context, state) => const ShipperInquiryView()),
      GoRoute(path: '/shipper-reservation-list', builder: (context, state) => const ShipperReservationView()),
      GoRoute(path: '/shipper-favorite-address', builder: (context, state) => const ShipperFavoriteAddressView()),
      GoRoute(path: '/shipper-faq', builder: (context, state) => const ShipperFaqView()),
    ],
  );
});
