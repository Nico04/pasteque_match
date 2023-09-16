import 'package:fetcher/fetcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pasteque_match/firebase_options.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'pages/main.page.dart';
import 'pages/register.page.dart';
import 'resources/app_theme.dart';
import 'services/names_service.dart';
import 'services/storage_service.dart';

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

  // Set default intl package locale
  Intl.defaultLocale = App.defaultLocale.toString();

  // Init shared pref
  await StorageService.init();

  // Init Names Service
  try {
    await NamesService.instance.load();
  } catch(e, s) {
    debugPrint('[NamesService] Error while loading database');
    reportError(e, s);
    // TODO go to an error page
  }

  // Init App Service
  AppService.instance.init();

  // Start App
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // Default locale
  static const defaultLocale = Locale('fr');

  /// Global key for the App's main navigator
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// The [BuildContext] of the main navigator.
  /// We may use this on showMessage, showError, openDialog, etc.
  static BuildContext get navigatorContext => _navigatorKey.currentContext!;

  @override
  Widget build(BuildContext context) {
    // Set orientations.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

    // Build app
    return DefaultFetcherConfig(
      config: FetcherConfig(
        onDisplayError: showError,
        onError: AppService.instance.handleError,
      ),
      child: MaterialApp(
        title: 'Pastèque Match',
        supportedLocales: const [App.defaultLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildAppTheme(),
        navigatorKey: _navigatorKey,
        home: AppService.instance.hasLocalUser ? const MainPage() : const RegisterPage(),
      ),
    );
  }
}
