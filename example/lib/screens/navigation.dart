import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class DismissMe extends Mutation<AppStore> {
  @override
  exec() {
    // does nothing
  }
}

class NavigationExample extends StatelessWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navigation")),
      body: NotifyOn(
        mutations: {
          DismissMe: (ctx, mut) async {
            if (!ctx.mounted) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content: Text("This screen will be closed in 2 seconds")),
            );
            await Future.delayed(Duration(seconds: 2));
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          }
        },
        child: Center(
          child: ElevatedButton(
            child: Text("Execute mutation"),
            onPressed: () {
              DismissMe();
            },
          ),
        ),
      ),
    );
  }
}
