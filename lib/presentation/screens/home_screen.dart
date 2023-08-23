import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:push_and_local_notification/presentation/bloc/notifications/notifications_bloc.dart';

import '../../domain/entity/push_message.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: context
            .select((NotificationsBloc bloc) => Text('${bloc.state.status}')),
        actions: [
          IconButton(
              onPressed: () {
                context.read<NotificationsBloc>().solicitarPermisis();
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications =
        context.watch<NotificationsBloc>().state.notifications;
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final PushMessage notificacion = notifications[index];
        return ListTile(
          onTap: () => context.push('/details/${notificacion.messageId}'),
          title: Text(notificacion.title),
          subtitle: Text(notificacion.body),
          leading: notificacion.imageUrl != null
              ? Image.network(notificacion.imageUrl!)
              : null,
        );
      },
    );
  }
}
