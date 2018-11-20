import 'package:flutter_storekeeper/store_keeper/http.dart';
import 'package:flutter_storekeeper/store_keeper/store_keeper.dart';
import 'store.dart';

class IncrementA extends Mutation<Store> {
  void exec() {
    store.counterA++;
  }
}

class IncrementB extends Mutation<Store> {
  void exec() {
    store.counterB++;
  }
}

class MarketWatch extends Mutation<Store> with HttpEffects {
  @override
  Request exec() {
    return HttpRequest(
      method: "GET",
      url: "https://www.google.com",
      params: {
        "q": "flutter",
      },
    );
  }

  @override
  void error(Response response) {}

  @override
  void fail(Response response) {
    // TODO: implement fail
  }

  @override
  void success(Response response) {
    // TODO: implement success
  }
}

class MarketWatchResponse extends Response {
  MarketWatchResponse() : super("", 200);
}
