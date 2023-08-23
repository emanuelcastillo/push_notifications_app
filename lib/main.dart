import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_and_local_notification/config/app_theme/app_theme.dart';
import 'package:push_and_local_notification/config/router/app_router.dart';
import 'package:push_and_local_notification/presentation/bloc/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsBloc.initFiebassesNotifi();

  runApp(MultiBlocProvider(
    providers: [BlocProvider(create: (context) => NotificationsBloc())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: AppTheme().getTheme(),
      builder: (context, child) =>
          HandleNotificationsInteractions(child: child!),
    );
  }
}

class HandleNotificationsInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotificationsInteractions({super.key, required this.child});

  @override
  State<HandleNotificationsInteractions> createState() =>
      _HandleNotificationsInteractionsState();
}

class _HandleNotificationsInteractionsState
    extends State<HandleNotificationsInteractions> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    context.read<NotificationsBloc>().handleRemoteMessage(message);
    final id = message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '';
    if (message.data['type'] == 'chat') {
      appRouter.push(
        '/details/$id',
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
