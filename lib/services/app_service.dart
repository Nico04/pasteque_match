import 'dart:async';

import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/dialogs/match_dialog.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/services/names_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/invalid_operation_exception.dart';
import 'package:pasteque_match/utils/exceptions/unauthorized_exception.dart';

import 'notification_sender_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class AppService {
  //#region Global
  /// App Service instance singleton
  static final instance = AppService();

  /// Database access
  static final database = DatabaseService.instance;
  static final names = NamesService.instance.names;

  /// Notifications
  late final NotificationService notificationService;
  FirebaseMessagingSenderService? _fcmSender;
  FirebaseMessagingSenderService get fcmSender => _fcmSender ??= FirebaseMessagingSenderService();

  /// User
  UserSession? userSession;
  String? get userId => userSession?.userId;
  bool get hasLocalUser => userSession != null;

  void init() {
    // Load user
    final userId = StorageService.readUserId();
    if (userId != null) userSession = UserSession(userId);

    // Init notifications
    notificationService = NotificationService(onNotificationReceived);
  }

  /// Get matches between user likes and partner likes
  /// Return sorted list of matched ids
  List<String> getMatches(Iterable<String> userLikes, Iterable<String> partnerLikes) {
    // Build matches
    final matchedIds = userLikes.where(partnerLikes.contains);

    // Return sorted list
    final nameOrderIndexes = userSession!.user!.nameOrderIndexes;
    return matchedIds.toList(growable: false)..sort((a, b) {
      // Sort by user order indexes first
      final comparison = (nameOrderIndexes[a] ?? double.infinity).compareTo(nameOrderIndexes[b] ?? double.infinity);
      if (comparison != 0) return comparison;

      // Then by name
      return a.compareTo(b);
    });
  }

  /// Save properties sort type to local storage
  Future<void> saveVoteSortType(VoteSortType value) => StorageService.saveVoteSortType(value.index);

  /// Get properties sort type from local storage
  VoteSortType get voteSortType => VoteSortType.values.elementAtOrNull(StorageService.voteSortType ?? -1) ?? VoteSortType.values.first;
  //#endregion

  //#region Notifications
  /// Update the Firebase Messaging token for the current user, if needed.
  /// Token should only changes when app's data is lost, or when the user logs out.
  /// But because user has only one token while using several devices, the best and easiest way to handle this is to check the token each time the app is launched,
  /// so that the last used device will receive notifications.
  Future<void> updateFirebaseMessagingTokenSafe() async {
    try {
      // Fetch server token
      final user = await userSession!.userStream.first;
      final serverToken = user.fcmToken;

      // Read local token
      final localToken = await notificationService.getToken();

      // Update token if needed
      if (localToken != serverToken) {
        await database.setUserFcmToken(userId!, localToken);
        debugPrint('[FirebaseMessaging] token updated');
      }
    } catch (e, s) {
      // Just report
      reportError(e, s);
    }
  }

  /// Called when a notification is received while the app is running in the foreground.
  void onNotificationReceived(String? title, String? body) {
    // Display notification
    final message = [title, body].toLines();
    if (message.isNotEmpty) {   // May be empty if the notification is silent (data-only notification)
      showMessage(message);
    }
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
  Future<void> setUserVoteSafe(String groupId, SwipeValue value) async {
    debugPrint('[Swipe] ${value.name} "$groupId"');
    try {
      final oldValue = userSession?.user?.votes[groupId]?.value;

      // Apply vote
      await database.setUserVote(userId!, groupId, value);

      // Is it a match ?
      final partner = userSession?.partner;
      if (value.isLike && partner != null && oldValue?.isLike != true) {
        final partnerVote = partner.votes[groupId];
        if (partnerVote?.value.isLike == true) {
          // Open dialog
          MatchDialog.open(App.navigatorContext, groupId);

          // Send notification
          if (partner.fcmToken != null) {
            await fcmSender.send('Nouveau match !', 'Votre partenaire à aimé $groupId', partner.fcmToken!);
          }
        }
      }
    } catch(e, s) {
      // Report error first
      reportError(e, s);

      // Update UI
      showError(App.navigatorContext, e);
    }
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

  Future<void> setNameOrderIndexes(List<String> names, int newIndex) async {
    // Get order indexes to change
    final ordersToChange = _getNameOrderIndexesToChange(names, newIndex);
    if (ordersToChange.isEmpty) return;

    // Update in database
    return database.setUserNameOrderIndexes(userId!, ordersToChange);
  }

  /// After a name group has been moved in the list,
  /// where [names] is the new list of names,
  /// and [newIndex] is the new index of the moved name,
  /// return the map of name order indexes to change in storage.
  NameOrderIndexes _getNameOrderIndexesToChange(List<String> names, int newIndex) {
    if (names.length <= 1) return {};
    final NameOrderIndexes orderIndexesToChange = {};

    // Helper to get order index of a group, either from user data or from being changed indexes
    double? getOrderIndex(String? groupId) => userSession!.user!.nameOrderIndexes[groupId] ?? orderIndexesToChange[groupId];

    // Get neighbors order indexes
    final previousGroup = names.elementAtOrNull(newIndex - 1);
    final nextGroup = names.elementAtOrNull(newIndex + 1);

    final previousGroupOrder = newIndex == 0 ? 0.0 : getOrderIndex(previousGroup);
    final nextGroupOrder = getOrderIndex(nextGroup);

    // If previous or next order index is null, fill it up
    if (previousGroupOrder == null || nextGroupOrder == null) {
      for (int i = 0; i <= newIndex; i++) {
        final groupId = names[i];
        final orderIndex = getOrderIndex(groupId);

        // Find first non-null order index in list
        if (orderIndex == null || i == newIndex) {
          // Get previous group's order index
          final previousGroupOrder = i == 0 ? 0.0 : getOrderIndex(names[i - 1])!;
          orderIndexesToChange[groupId] = previousGroupOrder.ceil() + 1.0;
        }
      }
      return orderIndexesToChange;
    }

    // Otherwise, compute new order index between neighbors
    final newOrderIndex = (previousGroupOrder + nextGroupOrder) / 2.0;
    final movedGroupId = names[newIndex];
    orderIndexesToChange[movedGroupId] = newOrderIndex;
    return orderIndexesToChange;
  }

  void deleteUser() {
    database.deleteUser(userId!, userSession?.partner?.id).then((_) => showMessage('Votre compte a été supprimé'));
    logOut();
  }
  //#endregion

  //#region Other
  void handleError(Object exception, StackTrace stack, {dynamic reason}) {
    // Report error
    reportError(exception, stack, reason: reason);

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
    if (warnUser) showMessage('Vous avez été déconnecté', isError: true);

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
