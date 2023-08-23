part of 'notifications_bloc.dart';

class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;
  const NotificationStatusChanged(this.status);
}

class NotificationStatusReceived extends NotificationsEvent {
  final PushMessage pMessage;
  const NotificationStatusReceived(this.pMessage);
}
