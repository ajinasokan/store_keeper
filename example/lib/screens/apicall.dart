import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:example/store.dart';

abstract class HttpEffects implements SideEffects<http.Request> {
  @override
  Future<void> branch(http.Request result) async {
    final response = await http.Response.fromStream(await result.send());

    if (response.statusCode == 200) {
      success(response);
    } else {
      fail(response);
    }
  }

  void success(http.Response response) {}
  void fail(http.Response response) {}
}

class FetchIP extends Mutation<AppStore> with HttpEffects {
  String err = "";

  bool forceError;
  FetchIP({this.forceError = false});

  http.Request exec() {
    store.ip = "";
    store.isFetchingIP = true;
    if (forceError)
      return http.Request("GET", Uri.parse("https://unknown.domain"));
    else
      return http.Request("GET", Uri.parse("https://icanhazip.com"));
  }

  void success(http.Response response) {
    store.isFetchingIP = false;
    store.ip = response.body;
  }

  void fail(http.Response response) {
    store.isFetchingIP = false;
    err = "Couldn't fetch. Error ${response.statusCode}.";
  }

  @override
  void exception(e, StackTrace s) {
    store.isFetchingIP = false;
    err = "Unexpected error occurred.";
    // print exception and trace
    super.exception(e, s);
  }
}

class APICallExample extends StatelessWidget {
  void onFetchIP(BuildContext ctx, Mutation mut) {
    final err = (mut as FetchIP).err;
    if (err.isNotEmpty) {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [FetchIP]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(
        title: Text("API Call"),
        actions: <Widget>[
          if (store.isFetchingIP)
            Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: NotifyOn(
        mutations: {FetchIP: onFetchIP},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("IP: ${store.ip}"),
              RaisedButton(
                child: Text("Make API Call"),
                onPressed: () {
                  FetchIP();
                },
              ),
              RaisedButton(
                child: Text("Make API Call (with error)"),
                onPressed: () {
                  FetchIP(forceError: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
