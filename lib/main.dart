import 'package:amuga/providers/events_provider.dart';
import 'package:amuga/providers/initstate_provider.dart';
import 'package:amuga/providers/map_provider.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/providers/path_provider.dart';
import 'package:amuga/providers/routes_provider.dart';
import 'package:amuga/providers/stop_provider.dart';
import 'package:amuga/widgets/main_menu_widget.dart';
import 'package:amuga/widgets/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets/amuga_map_widget.dart';
import 'package:amuga/themes/default.dart' as defaultTheme;
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<InitStateProvider>(
            create: (_) => InitStateProvider()),
        ChangeNotifierProvider<StopProvider>(create: (_) => StopProvider()),
        ChangeNotifierProvider<MarkersProvider>(
            create: (_) => MarkersProvider()),
        ChangeNotifierProvider<PathProvider>(create: (_) => PathProvider()),
        ChangeNotifierProvider<RoutesProvider>(create: (_) => RoutesProvider()),
        ChangeNotifierProvider<MapProvider>(create: (_) => MapProvider()),
        ChangeNotifierProvider<EventProvider>(create: (_) => EventProvider())
      ],
      child: AmugaApp(),
    ),
  );
}

class AmugaApp extends StatefulWidget {
  const AmugaApp({Key key}) : super(key: key);

  @override
  _AmugaAppState createState() => _AmugaAppState();
}

class _AmugaAppState extends State<AmugaApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // check if it's a first start
    //print("Percentage : ${Provider.of<InitStateProvider>(context).percentage}");
    //if (Provider.of<InitStateProvider>(context).percentage < 1) {
    if (Provider.of<MarkersProvider>(context).percentage +
            Provider.of<RoutesProvider>(context).percentage <
        1.0) {
      return MaterialApp(
        title: 'Amuga Mon Trajet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WelcomeScreen(),
      );
    } else {
      AppBar appBar = AppBar(
        backgroundColor: defaultTheme.kIconsColor,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.bell,
              size: 20.0,
            ),
            onPressed: () {
              print('action button pressed');
            },
          ),
        ],
      );

      Widget child = MyHomePage(appBar: appBar);
      child = CustomMenuDrawer(child: child);
      return MaterialApp(
        title: 'Amuga Mon Trajet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: child,
      );
    }
  }
}

class MyHomePage extends StatefulWidget {
  final AppBar appBar;

  MyHomePage({Key key, this.appBar}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: AmugaMap(),
      resizeToAvoidBottomInset: false,
    );
  }
}
