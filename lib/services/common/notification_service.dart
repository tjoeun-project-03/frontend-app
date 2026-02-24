import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../views/shipper/tracking/shipperEvaluationView.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settingsValue = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      // 에러 해결: 현재 버전에서는 'settings:' 라는 이름의 매개변수를 요구함
      settings: settingsValue,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'evaluation') {
          // 알림 클릭 시 전역 키를 사용하여 평가 화면으로 이동
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const ShipperEvaluationView()),
          );
        }
      },
    );

    // 안드로이드 13 이상을 위한 권한 요청 (알림이 안 뜨는 주원인)
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  }

  Future<void> showDeliveryCompleteNotification() async {
    // 에러 해결: AndroidNotificationDetails의 첫 두 인자는 이름 없이 넣어야 함
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'delivery_channel', // positional 1: channelId
      '운송 완료 알림',      // positional 2: channelName
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // 에러 해결: show 함수의 모든 인자에 이름을 붙여서 전달
    await _notifications.show(
      id: 0,
      title: '운송 완료!',
      body: '하차가 완료되었습니다. 기사님을 평가해 주세요.',
      notificationDetails: details,
      payload: 'evaluation',
    );
  }
}