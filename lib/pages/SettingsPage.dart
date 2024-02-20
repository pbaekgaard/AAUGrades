import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:stads/boxes/boxes.dart';
import 'package:stads/classes/coursegrade.dart';
import 'package:stads/providers/SettingsProvider.dart';
import 'package:stads/providers/StadsGradeProvider.dart';
import 'package:stads/providers/Themes.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int selectedFetchInterval;
  late bool? autoFetchEnabled;
  late bool fetchOnStartupEnabled;
  late bool notificationsEnabled;
  late ThemeMode _themeGroupValue;
  late ThemeService _themeManager;
  String? _version;
  late SettingsProvider _settingsProvider;

  static List<DropdownMenuItem> autoFetchOptions = [
    const DropdownMenuItem(value: 15, child: Text("Every fifteen minutes")),
    const DropdownMenuItem(value: 30, child: Text("Every half hour")),
    const DropdownMenuItem(value: 60, child: Text("Every hour")),
    const DropdownMenuItem(value: 180, child: Text("Every third hour")),
    const DropdownMenuItem(value: 360, child: Text("Every sixth hour")),
    const DropdownMenuItem(value: 720, child: Text("Every twelfth hour")),
    const DropdownMenuItem(value: 1440, child: Text("Every day")),
  ];

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _themeManager = Provider.of<ThemeService>(context, listen: false);
    _themeGroupValue = _themeManager.themeMode;
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    fetchOnStartupEnabled = _settingsProvider.fetchOnStartup;
    autoFetchEnabled = _settingsProvider.autoFetchingEnabled;
    notificationsEnabled = _settingsProvider.notificationsEnabled;
    selectedFetchInterval = _settingsProvider.fetchInterval;
    print(fetchOnStartupEnabled);
    print(_settingsProvider.autoFetchingEnabled);
  }

  void _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    setState(() {
      _version = version;
    });
  }

  Future openUrl(String url) async {
    // Replace 'https://example.com/privacy-policy' with the URL of your privacy policy
    final Uri Url = Uri.parse(url);
    if (await canLaunchUrl(Url)) {
      await launchUrl(Url, mode: LaunchMode.inAppBrowserView);
    } else {
      print('could not launch');
    }
  }

  void sendTestNotification() {
    StadsGradesProvider().SendGradeNotification("TEST NOTIFICATION");
  }

  @override
  Widget build(BuildContext context) {
    return autoFetchEnabled != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Grade Updates",
                        style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20)),
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fetch on startup",
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                  Text(
                                    "Fetch new grades when opening the app.",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  )
                                ],
                              ),
                              Checkbox(
                                value: fetchOnStartupEnabled,
                                onChanged: (value) => {
                                  setState(
                                    () {
                                      fetchOnStartupEnabled = value!;
                                      _settingsProvider.fetchOnStartup = value;
                                    },
                                  ),
                                  print(_settingsProvider.fetchOnStartup)
                                },
                              )
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Auto-fetching",
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                  Text(
                                    "Automatically fetch grades in the background.",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  )
                                ],
                              ),
                              Checkbox(
                                value: autoFetchEnabled,
                                onChanged: (value) => {
                                  setState(
                                    () {
                                      autoFetchEnabled = value;
                                      if (value == false) {
                                        Workmanager().cancelAll();
                                      }
                                      _settingsProvider.autoFetchingEnabled =
                                          value!;
                                    },
                                  )
                                },
                              )
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fetching interval",
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                  Text(
                                    "Interval to fetch grades",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  )
                                ],
                              ),
                              DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 14),
                                iconSize: 0,
                                alignment: AlignmentDirectional.centerEnd,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                items: autoFetchOptions,
                                isExpanded: false,
                                value: selectedFetchInterval,
                                onChanged: (value) => {
                                  setState(
                                    () {
                                      selectedFetchInterval = value;
                                      _settingsProvider.fetchInterval = value;
                                    },
                                  )
                                },
                              ))
                            ]),
                      ],
                    )
                  ],
                ),
                /*
                NOTIFICATION SECTION
               */
                Container(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notifications",
                            style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20)),
                        Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Notifications on new grades",
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        ),
                                        Text(
                                          "Get a notification when you have received a new grade on STADS!",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        )
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: notificationsEnabled,
                                    onChanged: (value) => {
                                      setState(
                                        () {
                                          notificationsEnabled = value!;
                                          _settingsProvider
                                              .notificationsEnabled = value;
                                        },
                                      )
                                    },
                                  ),
                                ]),
                          ],
                        )
                      ],
                    )),
                /*
              THEME SECTION
              */
                Container(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Theme",
                            style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20),
                          ),
                          Consumer<ThemeService>(
                              builder: (context, ThemeService theme, _) {
                            return RadioListTile(
                                title: Row(children: [
                                  const Icon(Symbols.night_sight_auto),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text("Follow System",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground)),
                                  )
                                ]),
                                contentPadding: const EdgeInsets.all(0),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: ThemeMode.system,
                                groupValue: _themeGroupValue,
                                onChanged: (val) => setState(() {
                                      _themeGroupValue = val!;
                                      _themeManager.themeMode = val;
                                    }));
                          }),
                          Consumer<ThemeService>(
                              builder: (context, ThemeService theme, _) {
                            return RadioListTile(
                                title: Row(children: [
                                  const Icon(Symbols.dark_mode),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text("Dark Mode",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground)),
                                  ),
                                ]),
                                contentPadding: const EdgeInsets.all(0),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: ThemeMode.dark,
                                groupValue: _themeGroupValue,
                                onChanged: (val) => setState(() {
                                      _themeGroupValue = val!;
                                      _themeManager.themeMode = val;
                                    }));
                          }),
                          Consumer<ThemeService>(
                              builder: (context, ThemeService theme, _) {
                            return RadioListTile(
                                title: Row(children: [
                                  const Icon(Symbols.light_mode),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text("Light Mode",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground)),
                                  ),
                                ]),
                                contentPadding: const EdgeInsets.all(0),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                value: ThemeMode.light,
                                groupValue: _themeGroupValue,
                                onChanged: (val) => setState(() {
                                      _themeGroupValue = val!;
                                      _themeManager.themeMode = val;
                                    }));
                          }),
                        ])),

                /* 
                ABOUT SECTION
              */
                Container(
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("About",
                            style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20)),
                        Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Version",
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        ),
                                        Text(
                                          "Your current version of AAU Grades.",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _version ?? '-',
                                    style: GoogleFonts.inter(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  )
                                ]),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: TextButton(
                                child: Text("Privacy Policy"),
                                onPressed: () async {
                                  await openUrl(
                                      'https://pbaekgaard.github.io/stads/privacy_policy');
                                },
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1.5)))),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                child: Text("Open-Source Licenses"),
                                onPressed: () async {
                                  await openUrl(
                                      'https://pbaekgaard.github.io/stads/licenses');
                                },
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1.5)))),
                              ),
                            )
                          ],
                        )
                      ],
                    )),
                if (kDebugMode) ...[
                  Container(
                      padding: const EdgeInsets.only(
                        top: 24,
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DEVELOPER OPTIONS",
                              style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: sendTestNotification,
                                child: Text("Send Test Notification"),
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1.5)))),
                              ),
                              TextButton(
                                child: Text("Clear DB"),
                                onPressed: Provider.of<StadsGradesProvider>(
                                        context,
                                        listen: false)
                                    .clearDb,
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1.5)))),
                              )
                            ],
                          )
                        ],
                      ))
                ]
              ],
            ),
          )
        : CircularProgressIndicator();
  }
}
