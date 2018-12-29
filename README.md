```dart
// app.dart
export 'package:store_keeper/store_keeper.dart';

export 'package:app/models/index.dart';
export 'package:app/mutations/index.dart';
export 'package:app/constants/index.dart';
export 'package:app/components/index.dart';
export 'package:app/screens/index.dart';
export 'package:app/resources/index.dart';
```

```dart
// main.dart
import 'package:app/app.dart';


void main() {
  runApp(
    StoreKeeperProvider(
      store: Store(),
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    LoadStore();
  }

  @override
  Widget build(BuildContext context) {
    StoreKeeper.of(context).notifyOn([
      LoadStore,
      ToggleNightMode,
    ]);
    var store = StoreKeeper.of(context).getStore<Store>();
    if (!store.storeLoaded) return Container(color: Colors.white);

    var theme;
    if (store.nightMode) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      );
      theme = ThemeData.dark().copyWith(
        toggleableActiveColor: Colors.teal,
        accentColor: Colors.tealAccent,
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      );
      theme = ThemeData(
        primarySwatch: Colors.grey,
        primaryColorBrightness: Brightness.light,
        primaryColor: Colors.black,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      theme: theme,
      home: Main(),
    );
  }
}
```

```dart
// mutations.dart
import 'package:app/app.dart';

class LoadStore extends Mutation<Store> {
  Future<void> exec() async {
    var prefs = await SharedPreferences.getInstance();
    var json = prefs.getString("store");
    if (json != null) store.initFromJson(json);

    store.storeLoaded = true;
  }
}
```