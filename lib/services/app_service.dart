import 'dart:async';

import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/services/names_service.dart';
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
  static final names = NamesService.instance.names;

  // User session
  UserSession? userSession;
  String? get userId => userSession?.userId;
  bool get hasLocalUser => userSession != null;

  void init() {
    final userId = StorageService.readUserId();
    if (userId != null) userSession = UserSession(userId);
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
    userSession = UserSession(userId);
  }

  Future<void> choosePartner(String partnerId) async {
    // Check
    if (userSession?.hasPartner != true) throw const InvalidOperationException('Remove your current partner first');

    // Update database
    await database.setPartner(userId!, partnerId);
  }

  Future<void> removePartner() => database.removePartner(userId!, userSession!.partner!.id);

  Future<void> setUserVote(String groupId, SwipeValue value) => database.setUserVote(userId!, groupId, value);
  Future<void> clearUserVote(String groupId) => database.clearUserVote(userId!, groupId);
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
    // Clear user session
    userSession?.dispose();
    userSession = null;

    // Delete local data
    unawaited(StorageService.deleteAll());

    // Warn user
    if (warnUser) showMessage(App.navigatorContext, 'Vous avez été déconnecté', isError: true);

    // Go back to connexion page
    navigateTo(App.navigatorContext, (_) => const RegisterPage(), clearHistory: true);
  }
  //#endregion
}

class UserSession with Disposable {
  UserSession(this.userId) : _userStore = UserStore(userId) {
    // Listen to user changes
    StreamSubscription? subscription;
    subscription = userStream.listen((user) {
      // If user has a partner, listen to his changes
      if (user?.hasPartner == true) {
        if (_partnerStore == null) {
          _partnerStore = UserStore(user!.partnerId!);
          StreamSubscription? subscription;
          subscription = _partnerStore!.stream.listen(partnerStream.add, onError: partnerStream.addError, onDone: () {
            subscription?.cancel();
          });

          /* TODO listen to partner changes, and remove partner if not found
          debugPrint('[AppService] Partner ${user.partnerId} not found');
          await database.removePartner(user.id, user.partnerId!);
          showMessage(App.navigatorContext, 'Votre partenaire est introuvable', isError: true);
          */
        }
      }

      // Else, clear partner data
      else {
        _partnerStore?.dispose();
        _partnerStore = null;
        partnerStream.add(null, skipSame: true);
      }
    }, onDone: () => subscription?.cancel());
  }

  final String userId;

  final UserStore _userStore;
  EventStream<User?> get userStream => _userStore.stream;
  User? get user => userStream.valueOrNull;

  UserStore? _partnerStore;
  final partnerStream = EventStream<User?>();
  User? get partner => partnerStream.valueOrNull;
  bool get hasPartner => partner != null;

  @override
  void dispose() {
    _userStore.dispose();
    _partnerStore?.dispose();
    partnerStream.close();
    super.dispose();
  }
}
