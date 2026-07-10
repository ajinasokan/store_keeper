import 'dart:convert';
import 'package:store_keeper/store_keeper.dart';

class AppStore extends Store {
  // For api call example
  String ip = "";
  bool isFetchingIP = false;

  // For counter example
  int count = 0;

  // For debounce example
  String query = "";

  void fromJSON(String jstring) {
    count = json.decode(jstring)["count"];
  }

  String toJSON() {
    return json.encode({"count": count});
  }
}
