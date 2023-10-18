import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService  {
  NotificationService(this._onMessageReceived);

  /// Called when a notification is received while the app is running in the foreground.
  final void Function(String? title, String? body)? _onMessageReceived;

  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  Future<void> init() async {
    // Ask permission
    final status = (await FirebaseMessaging.instance.requestPermission()).authorizationStatus;
    if (status != AuthorizationStatus.authorized) return;

    // If the app is open and running in the foreground.
    _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationReceived);

    // If the app is closed, but still running in the background or fully terminated
    _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_onNotificationReceived);
  }

  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('[FirebaseMessaging] token: $token');
    return token;
  }

  void _onNotificationReceived(RemoteMessage message) {
    // Log
    debugPrint('[FirebaseMessaging] received: [title: ${message.notification?.title ?? '<empty>'}]');

    // Call callback
    _onMessageReceived?.call(message.notification?.title, message.notification?.body);
  }

  void unregister() {
    // Remove reception subscriptions
    _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = null;
    _onMessageSubscription?.cancel();
    _onMessageSubscription = null;

    // Invalidate FCM token
    FirebaseMessaging.instance.deleteToken();
  }
}
