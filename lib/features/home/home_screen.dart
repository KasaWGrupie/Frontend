import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/core/widgets/base_screen.dart';
import 'package:kasa_w_grupie/features/auth/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Kasa w Grupie',
      child: Center(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Witaj w Kasie w Grupie'),
                const SizedBox(height: 20),
                if (state is SignedInState)
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).go('/groups');
                    },
                    child: const Text('Go to Groups'),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).go('/login');
                    },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).go('/register');
                    },
                    child: const Text('Register'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
