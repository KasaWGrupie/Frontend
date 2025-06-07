import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/auth_cubit.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/cubits/group_join_requests_cubit.dart';
import 'package:kasa_w_grupie/cubits/user_cubit.dart';
import 'package:kasa_w_grupie/firebase_options.dart';
import 'package:kasa_w_grupie/cubits/edit_group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/add_expense_screen.dart';
import 'package:kasa_w_grupie/screens/edit_expense_screen.dart';
import 'package:kasa_w_grupie/screens/edit_group_screen/edit_group_screen.dart';
import 'package:kasa_w_grupie/screens/friends_screen/friends_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/group_screen.dart';
import 'package:kasa_w_grupie/screens/groups_screen/groups_screen.dart';
import 'package:kasa_w_grupie/screens/join_requests_screen.dart';
import 'package:kasa_w_grupie/screens/profile_screen.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/settlemnets_screen.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/screens/login_screen.dart';
import 'package:kasa_w_grupie/screens/register_screen.dart';
import 'package:kasa_w_grupie/screens/home_screen.dart';

import 'package:kasa_w_grupie/screens/add_group_screen/add_group_screen.dart';
import 'package:kasa_w_grupie/cubits/add_group_cubit.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';
import 'package:kasa_w_grupie/services/receipt_service.dart';
import 'package:kasa_w_grupie/services/settlements_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

import 'package:provider/provider.dart';

void main() async {
  await dotenv.load();
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
          routes: [
            GoRoute(
              path: ':groupId',
              builder: (context, state) => GroupScreen(
                groupId:
                    int.tryParse(state.pathParameters['groupId'] ?? '') ?? 0,
              ),
              routes: [
                GoRoute(
                  path: 'new_expense',
                  builder: (context, state) {
                    final groupId =
                        int.tryParse(state.pathParameters['groupId']!) ?? 0;
                    return BlocProvider<GroupCubit>(
                      create: (context) => GroupCubit(
                        groupId: groupId,
                        groupService: context.read(),
                        usersService: context.read(),
                        authService: context.read<AuthService>(),
                      ),
                      child: AddExpenseScreen(
                        expenseService: context.read(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'requests',
                  name: 'groupRequests',
                  builder: (context, state) {
                    final groupId =
                        int.tryParse(state.pathParameters['groupId'] ?? '') ??
                            0;
                    return BlocProvider(
                      create: (context) => GroupJoinRequestsCubit(
                        groupService: context.read<GroupService>(),
                        groupId: groupId,
                      )..fetchRequests(),
                      child: GroupJoinRequestsScreen(groupId: groupId),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit',
                  name: 'editGroup',
                  builder: (context, state) {
                    final groupId =
                        int.tryParse(state.pathParameters['groupId'] ?? '') ??
                            0;
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
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'settlements',
          builder: (context, state) => const SettlementsScreen(),
        ),
        GoRoute(
          path: 'edit_expense/:expenseId',
          builder: (context, state) {
            final expenseId = state.pathParameters['expenseId'] ?? "0";
            final expenseService = context.read<ExpenseService>();

            return FutureBuilder<Expense?>(
              future: expenseService.getExpenseById(expenseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading expense'));
                }

                final expense = snapshot.data!;
                return BlocProvider<GroupCubit>(
                  create: (context) => GroupCubit(
                    authService: context.read<AuthService>(),
                    groupId: expense
                        .id, // We should ideally get this from the expense
                    groupService: context.read(),
                    usersService: context.read(),
                  )..fetch(),
                  child: EditExpenseScreen(
                    expenseService: expenseService,
                    expense: expense,
                  ),
                );
              },
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
            return MultiProvider(
              providers: [
                Provider<UsersService>(
                  create: (context) => UsersServiceApi(),
                ),
                Provider<AuthService>(
                  create: (context) => FirebaseAuthService(
                      userService: context.read(),
                      firebaseAuth: FirebaseAuth.instance),
                ),
                BlocProvider<AuthCubit>(
                  create: (context) => AuthCubit(
                    authService: context.read(),
                  ),
                ),
                Provider<AuthService>(
                  create: (context) => FirebaseAuthService(
                      userService: context.read(),
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
                BlocProvider<UserCubit>(
                  create: (context) => UserCubit(context.read<UsersService>()),
                ),
                Provider<MoneyTransactionService>(
                    create: (context) => MoneyTransactionServiceMock(
                        authService: context.read<AuthService>())),
                Provider<FriendsService>(
                  create: (context) => MockFriendsService(
                    authService: context.read<AuthService>(),
                    usersService: context.read<UsersService>(),
                  ),
                ),
                Provider<GroupService>(
                  create: (context) => GroupServiceMock(
                    authService: context.read(),
                  ),
                ),
                BlocProvider<UserCubit>(
                  create: (context) => UserCubit(context.read<UsersService>()),
                ),
                Provider<ExpenseService>(
                  create: (context) => MockExpenseService(),
                ),
                Provider<MoneyTransactionService>(
                    create: (context) => MoneyTransactionServiceMock(
                        authService: context.read<AuthService>())),
                Provider<FriendsService>(
                  create: (context) => MockFriendsService(
                    usersService: context.read<UsersService>(),
                    authService: context.read<AuthService>(),
                  ),
                ),
                Provider<SettlementsService>(
                  create: (context) => SettlementsServiceMock(),
                ),
                Provider<ReceiptService>(
                  create: (context) => MockReceiptParserService(),
                ),
              ],
              child: child!,
            );
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
