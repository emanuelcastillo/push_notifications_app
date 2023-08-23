import 'package:go_router/go_router.dart';
import 'package:push_and_local_notification/presentation/screens/details_screen.dart';
import 'package:push_and_local_notification/presentation/screens/home_screen.dart';

final appRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  GoRoute(
      path: '/details/:id',
      builder: (context, state) => DetailsScreen(
            pushMessageId: state.pathParameters['id'] ?? '',
          )),
]);
