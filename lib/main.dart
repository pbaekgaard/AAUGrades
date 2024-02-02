import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:stads/pages/SignInPage.dart';
import 'package:stads/providers/SettingsProvider.dart';
import 'package:stads/providers/StadsGradeProvider.dart';
import 'package:stads/providers/Themes.dart';
import 'package:stads/pages/SettingsPage.dart';
import 'package:stads/pages/StatisticsPage.dart';
import 'package:stads/pages/AllGradesPage.dart';
import 'package:stads/providers/AuthProvider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';

// Callback dispatcher is what runs the autofetcher for the workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(((taskName, inputData) async {
    await Hive.initFlutter();
    Hive.registerAdapter(CourseGradeAdapter());
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'stads_channel',
          channelName: 'Stads Notifications',
          channelDescription: 'Notification channel for STADS grades',
        )
      ],
      debug: true,
    );
    await Hive.openBox<CourseGrade>(HiveBoxes.coursegrades);
    await StadsGradesProvider().fetchGrades();
    return Future.value(true);
  }));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CourseGradeAdapter());
  await Hive.openBox<CourseGrade>(HiveBoxes.coursegrades);
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'stads_channel',
        channelName: 'Stads Notifications',
        channelDescription: 'Notification channel for STADS grades',
      )
    ],
    debug: true,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
      statusBarColor: Colors.transparent));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(),
        ),
        ChangeNotifierProvider<ThemeService>(
            create: (context) => ThemeService()),
        ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider()),
      ],
      builder: (context, _) => MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (SettingsProvider().fetchOnStartup) {
      StadsGradesProvider().fetchGrades();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Starts the background task for autofetching
  Future startBackgroundFetching() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask('fetchTask', 'backgroundFetch',
        frequency: Duration(minutes: SettingsProvider().fetchInterval),
        initialDelay: Duration(minutes: SettingsProvider().fetchInterval),
        constraints: Constraints(networkType: NetworkType.connected));
  }

  // Stops the background task for autfetching
  Future stopBackgroundFetching() async {
    await Workmanager().cancelAll();
  }

  // Check for the App state (opened / minimized)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (SettingsProvider().fetchOnStartup) {
        StadsGradesProvider().fetchGrades();
      }
      if (SettingsProvider().autoFetchingEnabled) {
        await stopBackgroundFetching();
      }
    } else if (state == AppLifecycleState.paused) {
      if (SettingsProvider().autoFetchingEnabled) {
        await startBackgroundFetching();
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeService>(
      create: (context) => ThemeService(),
      builder: (context, snapshot) {
        final themeManager = Provider.of<ThemeService>(context);
        return MaterialApp(
          title: 'Overload',
          theme: light,
          darkTheme: dark,
          themeMode: themeManager.themeMode,
          home: const MyHomePage(title: 'AAU Grades'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() async {
    Hive.close();
    super.dispose();
  }

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _pages = <Widget>[
    const AllGradesPage(),
    const StatisticsPage(),
    const SettingsPage()
  ];

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
          if (!isAllowed)
            {AwesomeNotifications().requestPermissionToSendNotifications()}
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final authProvider = Provider.of<AuthProvider>(context);
    signOut() async {
      await authProvider.logout();
    }

    return FutureBuilder(
        future: authProvider.isLoggedIn(),
        builder: (context, snapshot) {
          final bool isLoggedIn = snapshot.data ?? false;
          if (!isLoggedIn) {
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    title: const Text(
                      "AAU GRADES",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    )),
                body: const SignInPage());
          } else {
            return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  surfaceTintColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  title: Text(
                    _selectedIndex == 2 ? "SETTINGS" : "AAU GRADES",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  actions: [
                    Container(
                      padding: const EdgeInsets.only(right: 24),
                      child: _selectedIndex != 2
                          ? IconButton(
                              onPressed: () async {
                                await StadsGradesProvider().fetchGrades();
                              },
                              icon: const Icon(Icons.refresh))
                          : IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: signOut),
                    )
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                body: Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 16),
                    child: _pages[_selectedIndex]),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border(
                          top: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer))),
                  child: BottomNavigationBar(
                    showUnselectedLabels: false,
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.list,
                          size: 26,
                        ),
                        label: 'Grades',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.show_chart,
                          size: 26,
                        ),
                        label: 'Statistics',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.settings,
                          size: 26,
                        ),
                        label: "Settings",
                      )
                    ],
                    onTap: _onItemTapped,
                    currentIndex: _selectedIndex,
                  ),
                )
                // This trailing comma makes auto-formatting nicer for build methods.
                );
          }
        });
  }
}
