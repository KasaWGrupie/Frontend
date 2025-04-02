import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/auth_cubit.dart';
import 'package:kasa_w_grupie/cubits/edit_group_cubit.dart';
import 'package:kasa_w_grupie/screens/edit_group_screen.dart';
import 'package:kasa_w_grupie/screens/friends_screen/friends_screen.dart';
import 'package:kasa_w_grupie/screens/groups_screen/groups_screen.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/screens/login_screen.dart';
import 'package:kasa_w_grupie/screens/register_screen.dart';
import 'package:kasa_w_grupie/screens/home_screen.dart';

import 'package:kasa_w_grupie/screens/add_group_screen/add_group_screen.dart';
import 'package:kasa_w_grupie/cubits/add_group_cubit.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';

import 'package:provider/provider.dart';

void main() async {
  runApp(
    const _App(),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) {
            BlocProvider.of<AuthCubit>(context).resetError();
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: 'addGroup',
          builder: (context, state) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: 'friends',
          builder: (context, state) => const FriendsScreen(),
        ),
        GoRoute(
          path: 'groups',
          builder: (context, state) => const GroupsScreen(),
        ),
        GoRoute(
          path: 'editGroup/:groupId',
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? "0";
            final authService = context.read<AuthService>();
            return BlocProvider(
              create: (context) {
                final cubit = EditGroupCubit(
                  groupService: GroupServiceMock(authService: authService),
                  friendsService: MockFriendsService(
                      currentUserId: authService.currentUser!.id),
                  authService: authService,
                  groupId: groupId,
                );
                cubit.loadGroup();
                return cubit;
              },
              child: EditGroupScreen(groupId: groupId),
            );
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    final loggedIn = BlocProvider.of<AuthCubit>(context).isSignedIn();
    final signingIn = state.matchedLocation == '/register';
    final inHome = state.matchedLocation == '/';
    if (inHome) return '/';
    if (!loggedIn) {
      if (signingIn) {
        return '/register';
      }
      return '/login';
    }
    return null;
  },
);

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (context) => AuthServiceMock()),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authService: context.read(),
          ),
        ),
        Provider<GroupService>(
          create: (context) => GroupServiceMock(
            authService: context.read(),
          ),
        ),
        BlocProvider<AddGroupCubit>(
          create: (context) => AddGroupCubit(
            groupService: context.read(),
          ),
        )
      ],
      child: MaterialApp.router(
        title: 'CashInGroup',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
