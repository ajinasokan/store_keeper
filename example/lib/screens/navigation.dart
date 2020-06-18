import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class DismissMe extends Mutation<AppStore> {
  exec() {
    // does nothing
  }
}

class NavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navigation")),
      body: NotifyOn(
        mutations: {
          DismissMe: (ctx, mut) async {
            Scaffold.of(ctx).showSnackBar(
              SnackBar(
                  content: Text("This screen will be closed in 2 seconds")),
            );
            await Future.delayed(Duration(seconds: 2));
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: RaisedButton(
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
