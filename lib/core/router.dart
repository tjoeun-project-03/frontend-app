import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import '../views/auth/startView.dart';
import '../views/auth/loginView.dart';
import '../views/auth/roleSelectionView.dart';
import '../views/auth/signupView.dart';
import '../views/auth/licenseCameraView.dart';
import '../views/shipper/home/shipperHomeView.dart';
import '../views/shipper/shipperNavControllerView.dart';
import '../views/shipper/home/shipperPaymentView.dart';
import '../views/shipper/tracking/shipperEvaluationView.dart';
import '../views/carrier/home/carrierHomeView.dart';
import '../views/carrier/mypage/carrierMyPageView.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey, // 라우터에 전역 키를 심어줌
    initialLocation: '/start', // 앱 실행 시 첫 화면
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionView(),
      ),
      GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: '/license-camera',
        builder: (context, state) {
          // signupView에서 보낸 데이터를 state.extra로 받아옵니다.
          final data = state.extra as Map<String, dynamic>;
          return LicenseCameraView(signupData: data);
        },
      ),
      GoRoute(
          path: '/shipper-home',
          builder: (context, state) => const ShipperNavController(),
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
              // 🚀 에러의 원인: 새로 추가된 필수 값들을 모두 넣어줘야 합니다!
              distance: data['distance'] as double,
              duration: data['duration'] as int,
              startLat: data['startLat'] as String,
              startLng: data['startLng'] as String,
              endLat: data['endLat'] as String,
              endLng: data['endLng'] as String,
            );
          }
          ),
      GoRoute(
        path: '/evaluation',
        builder: (context, state) => const ShipperEvaluationView(),
      ),
      GoRoute(path: '/carrier-home'
          , builder: (context, state) => const CarrierHomeView()
      ),
      GoRoute(
        path: '/carrier-mypage',
        builder: (context, state) => const CarrierMyPageView(),
      ),
    ],
  );
});