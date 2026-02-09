import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import '../views/auth/startView.dart';
import '../views/auth/loginView.dart';
import '../views/auth/roleSelectionView.dart';
import '../views/auth/signupView.dart';
import '../views/auth/licenseCameraView.dart';
import '../views/shipper/shipperHomeView.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
          builder: (context, state) => const LicenseCameraView(),
      ),
      GoRoute(
          path: '/shipper-home',
          builder: (context, state) => const ShipperHomeView(),
      ),
    ],
  );
});