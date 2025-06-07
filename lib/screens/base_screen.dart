import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({
    required this.child,
    this.title,
    this.customAppBar,
    this.floatingActionButton,
    this.appBarBottom,
    this.appBarActions,
<<<<<<< HEAD
=======
    this.backgroundColor,
>>>>>>> develop
    super.key,
  });

  final Widget child;
  final String? title;
  final PreferredSizeWidget? customAppBar;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBarBottom;
  final List<Widget>? appBarActions;
<<<<<<< HEAD
=======
  final Color? backgroundColor;

>>>>>>> develop

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: floatingActionButton,
<<<<<<< HEAD
      appBar: AppBar(
        title: Text(title),
        bottom: appBarBottom,
        actions: appBarActions,
      ),
=======
      appBar: customAppBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  bottom: appBarBottom,
                  actions: appBarActions,
                )
              : null),
>>>>>>> develop
      body: child,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  context.go('/groups');
                },
                icon: const Icon(Icons.list),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  context.go('/friends');
                },
                icon: const Icon(Icons.people),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  context.go('/settlements');
                },
                icon: const Icon(Icons.mail),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  context.go('/profile');
                },
                icon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
