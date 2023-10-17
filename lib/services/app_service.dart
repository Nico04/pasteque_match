import 'dart:async';

import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/dialogs/match_dialog.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/services/names_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/form_validation_exception.dart';
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

  // User
  UserSession? userSession;
  String? get userId => userSession?.userId;
  bool get hasLocalUser => userSession != null;

  void init() {
    final userId = StorageService.readUserId();
    if (userId != null) userSession = UserSession(userId);
  }

  List<String> getMatches(Iterable<String> userLikes, Iterable<String> partnerLikes) {
    // Build matches
    final matchedIds = userLikes.where(partnerLikes.contains);

    // Return sorted list
    return matchedIds.toList(growable: false)..sort();
  }
  //#endregion

  //#region Operations
  Future<void> registerUser(String username) async {
    // Check
    if (hasLocalUser) throw const InvalidOperationException('Déjà connecté');

    // Register user to database
    final userId = await database.addUser(username);

    // Save id to local storage
    await StorageService.saveUserId(userId);

    // Init user store
    userSession = UserSession(userId);
    debugPrint('[AppService] User $username registered');
  }

  /// Restore user login from id.
  /// Suppose user exists.
  Future<void> restoreUser(String userId) async {
    // Check
    if (hasLocalUser) throw const InvalidOperationException('Déjà connecté');

    // Save id to local storage
    await StorageService.saveUserId(userId);

    // Save session
    userSession = UserSession(userId);
    debugPrint('[AppService] User $userId restored');
  }

  Future<void> choosePartner(String partnerId) async {
    // Check
    if (userSession?.hasPartner == true) throw const InvalidOperationException('Supprimez votre partenaire actuel d\'abord');

    // Update database
    await database.setPartner(userId!, partnerId);
  }

  Future<void> removePartner() => database.removePartner(userId!, userSession!.partner!.id);

  /// Apply user's vote.
  /// Return true if it's a match.
  Future<bool> setUserVoteSafe(String groupId, SwipeValue value) async {
    debugPrint('[Swipe] ${value.name} "$groupId"');
    try {
      // Apply vote
      await database.setUserVote(userId!, groupId, value);

      // Is it a match ?
      final partner = userSession?.partner;
      if (value == SwipeValue.like && partner != null) {
        final partnerVote = partner.votes[groupId];
        if (partnerVote?.value == SwipeValue.like) {
          MatchDialog.open(App.navigatorContext, groupId);
          return true;
        }
      }
    } catch(e, s) {
      // Report error first
      reportError(e, s);

      // Update UI
      showError(App.navigatorContext, e);
    }
    return false;
  }

  Future<void> clearUserVoteSafe(String groupId) async {
    debugPrint('[Swipe] clear "$groupId"');
    try {
      // Clear vote
      await database.clearUserVote(userId!, groupId);
    } catch(e, s) {
      // Report error first
      reportError(e, s);

      // Update UI
      showError(App.navigatorContext, e);
    }
  }

  void deleteUser() {
    database.deleteUser(userId!, userSession?.partner?.id).then((_) => showMessage(App.navigatorContext, 'Votre compte a été supprimé'));
    logOut();
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
    // Clear user session
    userSession?.dispose();

    // Delete local data
    unawaited(StorageService.deleteAll());

    // Warn user
    if (warnUser) showMessage(App.navigatorContext, 'Vous avez été déconnecté', isError: true);

    // Go back to connexion page
    navigateTo(App.navigatorContext, (_) => const RegisterPage(), clearHistory: true).then((_) {
      // Clear session (after navigation, so widgets are disposed)
      userSession = null;
    });
  }
  //#endregion
}

class UserSession with Disposable {
  UserSession(this.userId) : _userStore = UserStore(userId) {
    // Listen to user changes
    StreamSubscription? subscription;
    subscription = userStream.listen((user) {
      // If user has a partner, listen to his changes
      if (user.hasPartner == true) {
        if (_partnerStore == null) {
          _partnerStore = UserStore(user.partnerId!);
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
  EventStream<User> get userStream => _userStore.stream;
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
