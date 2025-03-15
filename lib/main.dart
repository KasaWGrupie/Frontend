import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/features/auth/auth_cubit.dart';
import 'package:kasa_w_grupie/features/auth/auth_service.dart';
import 'package:kasa_w_grupie/features/auth/login_screen.dart';
import 'package:kasa_w_grupie/features/auth/register_screen.dart';
import 'package:kasa_w_grupie/features/home/home_screen.dart';
import 'package:kasa_w_grupie/features/add_group/add_group_screen.dart';
import 'package:kasa_w_grupie/features/add_group/add_group_cubit.dart';
import 'package:kasa_w_grupie/features/add_group/group_service.dart';
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
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: 'addGroup',
          builder: (context, state) => const CreateGroupScreen(),
        ),
      ],
    ),
  ],
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
        BlocProvider<AddGroupCubit>(
          create: (context) => AddGroupCubit(
              groupService: GroupServiceMock(authService: context.read())),
        ),
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
