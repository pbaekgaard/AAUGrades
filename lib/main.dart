import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stads/pages/SignInPage.dart';
import 'package:stads/providers/Themes.dart';
import 'package:stads/pages/SettingsPage.dart';
import 'package:stads/pages/StatisticsPage.dart';
import 'package:stads/pages/AllGradesPage.dart';
import 'package:stads/providers/AuthProvider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider<ThemeService>(
            create: (context) => ThemeService()),
        ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider()),
      ],
      builder: (context, _) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  _refreshDatabase() async {
    setState(() {});
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
                  backgroundColor: Theme.of(context).colorScheme.background,
                  title: Text(
                    _selectedIndex == 2 ? "SETTINGS" : "AAU GRADES",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  actions: [
                    Container(
                      padding: const EdgeInsets.only(right: 24),
                      child: _selectedIndex != 2
                          ? IconButton(
                              onPressed: _refreshDatabase,
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
                        const EdgeInsetsDirectional.symmetric(horizontal: 24),
                    child: _pages[_selectedIndex]),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      border: Border(
                          top: BorderSide(
                              width: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer))),
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
