import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/auth_cubit.dart';
import 'package:kasa_w_grupie/firebase_options.dart';
import 'package:kasa_w_grupie/cubits/edit_group_cubit.dart';
import 'package:kasa_w_grupie/screens/edit_group_screen/edit_group_screen.dart';
import 'package:kasa_w_grupie/screens/friends_screen/friends_screen.dart';
import 'package:kasa_w_grupie/screens/groups_screen/groups_screen.dart';
import 'package:kasa_w_grupie/screens/profile_screen.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/screens/login_screen.dart';
import 'package:kasa_w_grupie/screens/register_screen.dart';
import 'package:kasa_w_grupie/screens/home_screen.dart';

import 'package:kasa_w_grupie/screens/add_group_screen/add_group_screen.dart';
import 'package:kasa_w_grupie/cubits/add_group_cubit.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

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

            return BlocProvider(
              create: (context) => EditGroupCubit(
                groupService: context.read<GroupService>(),
                friendsService: context.read<FriendsService>(),
                authService: context.read<AuthService>(),
                groupId: groupId,
              )..loadGroup(),
              child: EditGroupScreen(groupId: groupId),
            );
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
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
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CashInGroup',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
      ),
      routerConfig: _router,
      builder: (context, child) => FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(providers: [
              Provider<AuthService>(
                create: (context) => FirebaseAuthService(
                    userService: UsersServiceMock(),
                    firebaseAuth: FirebaseAuth.instance),
              ),
              BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(
                  authService: context.read(),
                ),
              ),
              BlocProvider<AddGroupCubit>(
                create: (context) => AddGroupCubit(
                  groupService: GroupServiceMock(authService: context.read()),
                ),
              ),
              Provider<GroupService>(
                create: (context) => GroupServiceMock(
                  authService: context.read(),
                ),
              ),
              Provider<FriendsService>(
                create: (context) => MockFriendsService(
                  authService: context.read<AuthService>(),
                ),
              ),
            ], child: child!);
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
