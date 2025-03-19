import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.appBarBottom,
    super.key,
  });

  final Widget child;
  final String title;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBarBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: Text(title),
        bottom: appBarBottom,
      ),
      body: child,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {

                  context.go('/addGroup');

                },
                icon: const Icon(Icons.list),
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
