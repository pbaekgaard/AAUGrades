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
      debug: false,
    );
    await Hive.openBox<CourseGrade>(HiveBoxes.coursegrades);
    StadsGradesProvider().fetchGrades();
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
    debug: false,
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
        ChangeNotifierProvider<StadsGradesProvider>(
            create: (context) => StadsGradesProvider()),
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
  }

  @override
  void didChangeDependencies() {
    if (Provider.of<SettingsProvider>(context, listen: false).fetchOnStartup) {
      Provider.of<StadsGradesProvider>(context, listen: false).fetchGrades();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Starts the background task for autofetching
  Future startBackgroundFetching() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask('fetchTask', 'backgroundFetch',
        frequency: Duration(
            minutes: Provider.of<SettingsProvider>(context, listen: false)
                .fetchInterval),
        initialDelay: Duration(
            minutes: Provider.of<SettingsProvider>(context, listen: false)
                .fetchInterval),
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
      if (Provider.of<SettingsProvider>(context, listen: false)
          .fetchOnStartup) {
        Provider.of<StadsGradesProvider>(context, listen: false).fetchGrades();
      }
      if (Provider.of<SettingsProvider>(context, listen: false)
          .autoFetchingEnabled) {
        await stopBackgroundFetching();
      }
    } else if (state == AppLifecycleState.paused) {
      if (Provider.of<SettingsProvider>(context, listen: false)
          .autoFetchingEnabled) {
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
                  surfaceTintColor: Colors.transparent,
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
                                Provider.of<StadsGradesProvider>(context,
                                        listen: false)
                                    .fetchGrades();
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
