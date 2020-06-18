import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class CallmeBack extends Mutation<AppStore> {
  String message;

  exec() {
    message = "Hello from callback";
  }
}

class CallbackExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Callback")),
      body: NotifyOn(
        mutations: {
          CallmeBack: (ctx, mut) {
            final message = (mut as CallmeBack).message;
            Scaffold.of(ctx).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        child: Center(
          child: RaisedButton(
            child: Text("Execute mutation"),
            onPressed: () {
              CallmeBack();
            },
          ),
        ),
      ),
    );
  }
}
