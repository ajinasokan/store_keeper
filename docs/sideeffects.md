## Side effects

This is very similar to Redux Thunk or Redux Saga. You execute one mutation and based on its result you execute something else. A simple example will be, you make an API call, if it succeeds you parse it and update store otherwise show a SnackBar with error message.

This pattern is to organize mutations as your app grows.

Structure of a side effect is like this:

```dart
mixin SideEffects<ON> {
  dynamic branch(ON result);
}
```

If a mutation extends a `SideEffects` instance, after execution of `exec` in the mutation the result is given to the `branch` of the side effect. Based on the implementation of this mixin behaviour can be defined.

## Example - HTTP API Call

```dart
import 'package:http/http.dart' as http;

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

class FetchNews extends Mutation<AppStore> with HttpEffects {
  String err = "";

  http.Request exec() {
    store.news = [];
    store.isFetchingNews = true;
    
    return http.Request("GET", Uri.parse("https://news.api"));
  }

  success(http.Response response) {
    store.isFetchingNews = false;
    store.news = parseNews(response.body);
  }

  fail(http.Response response) {
    store.isFetchingNews = false;
    err = "Couldn't fetch. Error ${response.statusCode}.";
  }

  exception(e, StackTrace s) {
    store.isFetchingNews = false;
    err = "Unexpected error occurred.";
    // print exception and trace
    super.exception(e, s);
  }
}
```