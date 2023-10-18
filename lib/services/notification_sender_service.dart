import 'package:firebase_cloud_messaging_flutter/firebase_cloud_messaging_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/fcm_service_account.dart';

class FirebaseMessagingSenderService {
  final _server = FirebaseCloudMessagingServer(firebaseMessagingServiceAccount);

  /// Send a push notification
  /// Set [targetUserToken] to send to a specific user
  /// [firebase_cloud_messaging_flutter] doc specifies that you can leave 'token' and 'topic' empty to send to every registered user, but it throw 400 (bad request).
  Future<void> send(String title, String message, String targetUserToken) async {
    // Send notification
    final result = await _server.send(FirebaseSend(
      validateOnly: false,
      message: FirebaseMessage(
        token: targetUserToken,
        notification: FirebaseNotification(
          title: title,
          body: message,
        ),
        android: const FirebaseAndroidConfig(
          notification: FirebaseAndroidNotification(
            icon: 'ic_notification',
            color: '#53C4B8',
          ),
        ),
      ),
    ));

    // Check success
    if (!result.successful) throw FirebaseMessagingServiceException(result.statusCode, result.errorPhrase);
    debugPrint('[FirebaseMessaging] notification sent');
  }
}

class FirebaseMessagingServiceException {
  const FirebaseMessagingServiceException(this.statusCode, this.errorPhrase);

  final int statusCode;
  final String? errorPhrase;

  @override
  String toString() => '[$statusCode] $errorPhrase';
}
