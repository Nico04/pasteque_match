import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/widgets/themed/dialogs/pm_confirmation_dialog.dart';

import '_utils.dart';
import 'exceptions/connectivity_exception.dart';
import 'exceptions/displayable_exception.dart';
import 'exceptions/operation_canceled_exception.dart';
import 'exceptions/permission_exception.dart';
import 'exceptions/unauthorized_exception.dart';
import 'exceptions/unreported_exception.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonList = Iterable<dynamic>;
typedef OptionalValueChanged<T> = void Function([T value]);
typedef LabelBuilder<T> = String Function(T data);
typedef IconBuilder<T> = IconData Function(T data);

/// Navigate to a new pages.
/// Push a new pages built with [builder] on the navigation stack.
///
/// if [returnAfterPageTransition] is true, the Future will return as soon as the pages transition (animation) is over.
/// This is useful when you need an animation to keep running while the push transition is running, but to stop after the transition is over
/// (so that the animation is stopped during pop transition).
/// If null, will be set to true if [T] is not set.
///
/// if [animate] is false, the transition animation will be skipped.
Future<T?> navigateTo<T>(BuildContext context, WidgetBuilder builder, {
  bool removePreviousRoutesButFirst = false,
  int? removePreviousRoutesAmount,
  bool clearHistory = false,
  bool? returnAfterPageTransition,
  bool animate = true,
}) async {
  // Check arguments
  if ([removePreviousRoutesButFirst, removePreviousRoutesAmount, clearHistory]
      .where((a) => (a is bool ? a == true : a != null))
      .length > 1) {
    throw ArgumentError('only one of removePreviousRoutesUntilNamed, removePreviousRoutesButFirst, removePreviousRoutesAmount and clearHistory parameters can be set');
  }

  // Build route
  final route = MaterialPageRoute<T>(
    builder: builder,
  );

  // Navigate
  Future<T?> navigationFuture;
  if (removePreviousRoutesButFirst != true && removePreviousRoutesAmount == null && clearHistory != true) {
    navigationFuture = Navigator.of(context).push(route);
  } else {
    int removedCount = 0;
    navigationFuture = Navigator.of(context).pushAndRemoveUntil(
      route,
      (r) =>  (removePreviousRoutesButFirst != true || r.isFirst) &&
              (removePreviousRoutesAmount == null || removedCount++ >= removePreviousRoutesAmount) &&
              clearHistory != true,
    );
  }

  // Await
  returnAfterPageTransition ??= isTypeUndefined<T>();
  if (returnAfterPageTransition) {
    return await navigationFuture.timeout(route.transitionDuration * 2, onTimeout: () => null);
  } else {
    return await navigationFuture;
  }
}

/// Opens a generic dialog (pop-up)
Future<void> openDialog<T>({required BuildContext context, required WidgetBuilder builder, ValueChanged<T>? onResult}) async {
  final result = await showDialog<T>(
    context: context,
    builder: builder,
  );

  if (result != null) {
    onResult?.call(result);
  }
}

/// Open a confirmation pop-up, with an optional form.
Future<void> askConfirmation({
  required BuildContext context,
  required String title,
  required String caption,
  Widget? form,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirmation,
}) async {
  await openDialog<bool>(
    context: context,
    builder: (context) {
      return Center(
        child: PmConfirmationDialog(
          title: title,
          caption: caption,
          form: form,
          confirmText: confirmText,
          cancelText: cancelText,
        ),
      );
    },
    onResult: (confirm) {
      if (confirm == true) {
        onConfirmation?.call();
      }
    },
  );
}

/// Display an error to the user
Future<void> showError(BuildContext context, Object error) async {
  // Cancellation
  if (error is OperationCanceledException) {
    if (!error.silent) {
      showMessage(context, 'Opération annulée', isError: true);
    }
  }

  // Permission
  else if (error is PermissionDeniedException) {
    showMessage(context, 'Permission requise', isError: true);
  }

  // Bad connectivity
  else if (error is ConnectivityException) {
    showMessage(context, 'Vérifiez votre connexion internet', isError: true);
  }

  // Unauthorized
  else if (error is UnauthorizedException) {
    // Ignore error : handled by AppService.logout
  }

  // Unauthorized
  else if (error is FirebaseException) {
    showMessage(context, 'Erreur de communication avec la base de donnée', isError: true, details: error.message);
  }

  // Displayable exception
  else if (error is DisplayableException) {
    showMessage(context, error.toString(), isError: true);
  }

  // Other
  else {
    showMessage(context, 'Une erreur est survenue', isError: true, details: !kReleaseMode ? error.toString() : null);
  }
}

/// Report error to Crashlytics
Future<void> reportError(Object exception, StackTrace stack, {dynamic reason}) async {
  if (shouldReportException(exception)) {
    // Report to Crashlytics
    await FirebaseCrashlytics.instance.recordError(exception, stack, reason: reason);
  } else {
    // Just log
    debugPrint('Unreported error thrown: $exception');
  }
}

/// Indicate whether this exception should be reported
bool shouldReportException(Object? exception) =>
    exception != null &&
    exception is! UnreportedException &&
    exception is! SocketException &&
    exception is! TimeoutException;

/// Throw a [ConnectivityException] if there is not internet connection
Future<void> throwIfNoInternet() async {
  if (!(await isConnectedToInternet())) {
    debugPrint('API (✕) NO INTERNET');
    throw const ConnectivityException(ConnectivityExceptionType.noInternet);
  }
}

/// Return whether device has access to internet
Future<bool> isConnectedToInternet() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

/// Return true if string is null or empty
bool isStringNullOrEmpty(String? s) => s == null || s.isEmpty;

/// Return true if iterable is null or empty
bool isIterableNullOrEmpty<T>(Iterable<T>? iterable) => iterable == null || iterable.isEmpty;

/// Returns true if T1 and T2 are identical types.
/// This will be false if one type is a derived type of the other.
bool typesEqual<T1, T2>() => T1 == T2;

/// Returns true if T is not set, Null, void or dynamic.
bool isTypeUndefined<T>() => typesEqual<T, Object?>() || typesEqual<T, Null>() || typesEqual<T, void>() || typesEqual<T, dynamic>();

T dumbFromJson<T>(dynamic json) => json as T;

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? value) => DateTime.tryParse(value ?? '')?.toLocal();

  @override
  String? toJson(DateTime? value) => value?.toUtc().toIso8601String();
}

class NullableTimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();

  @override
  Timestamp? toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}

class RangeValuesConverter implements JsonConverter<RangeValues, String> {
  const RangeValuesConverter();

  @override
  RangeValues fromJson(String value) {
    final parts = value.split('|');
    return RangeValues(double.parse(parts[0]), double.parse(parts[1]));
  }

  @override
  String toJson(RangeValues value) => '${value.start}|${value.end}';
}
