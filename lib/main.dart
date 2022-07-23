import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pasteque_match/firebase_options.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'pages/register.page.dart';

void main() async {
  // Init Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Override default debugPrint
  debugPrint = (message, {wrapWidth}) {
    // Disable logging in release mode
    if (!kReleaseMode) debugPrintThrottled(message, wrapWidth: wrapWidth);

    // Send to Crashlytics journal
    if(message != null) FirebaseCrashlytics.instance.log(message);
  };

  // init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kReleaseMode) await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

  // Pass all Flutter's uncaught errors to Crashlytics.
  FlutterError.onError = (flutterErrorDetails) {
    if (shouldReportException(flutterErrorDetails.exception)) {
      FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
    }
  };

  // Start App
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // Default locale
  static const defaultLocale = Locale('fr');

  @override
  Widget build(BuildContext context) {
    // Set orientations.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

    // Build app
    return MaterialApp(
      title: 'Pastèque Match',
      supportedLocales: const [App.defaultLocale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const RegisterPage(),
    );
  }
}
