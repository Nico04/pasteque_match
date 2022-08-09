import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/invalid_operation_exception.dart';
import 'package:pasteque_match/utils/exceptions/unauthorized_exception.dart';

import 'storage_service.dart';

class AppService {
  //#region Global
  /// App Service instance singleton
  static final instance = AppService();

  /// Database access
  static final database = DatabaseService.instance;

  UserStore? _userStore;
  User? get user => _userStore?.cached;
  bool get hasLocalUser => _userStore != null;

  UserStore? _partnerStore;
  User? get partner => _partnerStore?.cached;
  bool get hasPartner => _partnerStore != null;

  void init() {
    final userId = StorageService.readUserId();
    if (userId != null) _userStore = UserStore(userId);
  }

  Future<User> initData() async {
    // Fetch user
    final user = await _userStore?.fetch();
    if (user == null) throw const UnauthorizedException();

    // Fetch his partner
    if (user.hasPartner) {
      _partnerStore = UserStore(user.partnerId!);
      final partner = await _partnerStore?.fetch();
      if (partner == null) {
        debugPrint('[AppService] Partner ${user.partnerId} not found');
        await database.removePartner(user.id, user.partnerId!);
        showMessage(App.navigatorContext, 'Votre partenaire est introuvable', isError: true);
      }
    }

    // Return user
    return user;
  }
  //#endregion

  //#region Operations
  Future<void> registerUser(String username) async {
    // Check
    if (hasLocalUser) throw const InvalidOperationException('Already registered');

    // Register user to database
    final userId = await database.addUser(username);

    // Save id to local storage
    await StorageService.saveUserId(userId);

    // Init user store
    _userStore = UserStore(userId);
  }

  Future<void> choosePartner(String partnerId) async {
    // Check
    if (hasPartner) throw const InvalidOperationException('Remove your current partner first');

    // Update database
    await database.setPartner(user!.id, partnerId);

    // Init partner store
    _partnerStore = UserStore(partnerId);
  }

  Future<void> setUserVote(String nameId, SwipeValue value) => database.setUserVote(user!.id, nameId, value);
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
    // Clear user & partner cache
    _userStore = null;
    _partnerStore = null;

    // Delete local data
    unawaited(StorageService.deleteAll());

    // Warn user
    if (warnUser) showMessage(App.navigatorContext, 'Vous avez été déconnecté', isError: true);

    // Go back to connexion page
    navigateTo(App.navigatorContext, (_) => const RegisterPage(), clearHistory: true);
  }
  //#endregion
}
