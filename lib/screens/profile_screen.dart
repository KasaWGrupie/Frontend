import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/auth_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final usersService = context.read<UsersService>();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is SignedInState) {
          return BaseScreen(
            title: 'Profile',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<User?>(
                future: usersService.getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = snapshot.data;
                  if (user == null) {
                    return const Center(child: Text('User profile not found'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user.pictureUrl.isNotEmpty
                            ? NetworkImage(user.pictureUrl)
                            : null,
                        child: user.pictureUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // User details
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sign out button
                      ElevatedButton.icon(
                        onPressed: () {
                          authCubit.signOut();
                          context.go('/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
