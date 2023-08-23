import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_and_local_notification/domain/entity/push_message.dart';
import 'package:push_and_local_notification/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_noti);
    on<NotificationStatusReceived>(_pmessage);
    _statusCheck();
    _foregroundMessage();
  }
  static Future<void> initFiebassesNotifi() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _noti(evet, emit) {
    emit(state.copyWith(status: evet.status));
    _getToken();
  }

  void _pmessage(NotificationStatusReceived evet, emit) {
    emit(
        state.copyWith(notifications: [evet.pMessage, ...state.notifications]));
  }

  void _statusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    final token = await messaging.getToken();
    print(token);
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification != null) {
      final notificacion = PushMessage(
          messageId:
              message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          sentDate: message.sentTime ?? DateTime.now(),
          data: message.data,
          imageUrl: Platform.isAndroid
              ? message.notification!.android?.imageUrl
              : message.notification!.android?.imageUrl);
      add(NotificationStatusReceived(notificacion));
    }
  }

  void _foregroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void solicitarPermisis() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exist) return null;

    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
  }
}
