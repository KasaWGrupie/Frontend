import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/features/auth/login_screen.dart';
import 'package:kasa_w_grupie/features/auth/register_screen.dart';
import 'package:kasa_w_grupie/features/home/home_screen.dart';

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
    return MaterialApp.router(
      title: 'CashInGroup',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
      ),
      routerConfig: _router,
    );
  }
}
