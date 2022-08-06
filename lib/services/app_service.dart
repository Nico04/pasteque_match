import 'dart:async';

import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/unauthorized_exception.dart';

import 'storage_service.dart';

class AppService {
  //#region Global
  /// App Service instance singleton
  static final instance = AppService();

  /// Database access
  static final database = DatabaseService.instance;

  User? get user => database.user.cached;
  bool get hasLocalUser => database.user.isInitiated;

  User? get partner => database.partner.cached;

  void init() {
    database.user.id = StorageService.readUserId();
  }
  //#endregion

  //#region Operations
  Future<void> registerUser(String username) async {
    // Register user to database
    final userId = await database.addUser(username);

    // Save id to local storage
    await StorageService.saveUserId(userId);

    // Init user store
    database.user.id = userId;
  }

  Future<void> choosePartner(String partnerId) async {
    // Update database
    await database.setPartner(user!.id, partnerId);

    // Init partner store
    database.partner.id = partnerId;    // TODO init this at app startup
  }
  //#endregion

  //#region Other
  void handleError(Object exception, StackTrace stack, {dynamic reason}) {
    // Report error
    unawaited(reportError(exception, stack, reason: reason));

    // Handle Unauthorized Exception
    if (exception is UnauthorizedException) {
      logOut(warnUser: true);
    }
  }

  void logOut({bool warnUser = false}) {
    // Delete local data
    unawaited(StorageService.deleteAll());

    // Warn user
    if (warnUser) showMessage(App.navigatorContext, 'Vous avez été déconnecté', isError: true);

    // Go back to connexion page
    navigateTo(App.navigatorContext, (_) => const RegisterPage(), clearHistory: true);
  }
  //#endregion
}
