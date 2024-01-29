import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:stads/providers/StadsGradeProvider.dart';
import 'package:stads/providers/Themes.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/foundation.dart' as Foundation;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedFetchInterval = "Every fifteen minutes";
  bool autoFetchEnabled = true;
  bool fetchOnStartupEnabled = true;
  bool notificationsEnabled = true;
  late ThemeMode _themeGroupValue;
  late ThemeService _themeManager;
  String? _version;

  static List<DropdownMenuItem> autoFetchOptions = [
    const DropdownMenuItem(
        value: "Every fifteen minutes", child: Text("Every fifteen minutes")),
    const DropdownMenuItem(
        value: "Every half hour", child: Text("Every half hour")),
    const DropdownMenuItem(value: "Every hour", child: Text("Every hour")),
    const DropdownMenuItem(
        value: "Every third hour", child: Text("Every third hour")),
    const DropdownMenuItem(
        value: "Every sixth hour", child: Text("Every sixth hour")),
    const DropdownMenuItem(
        value: "Every twelfth hour", child: Text("Every twelfth hour")),
    const DropdownMenuItem(value: "Every day", child: Text("Every day")),
  ];

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _themeManager = Provider.of<ThemeService>(context, listen: false);
    _themeGroupValue = _themeManager.themeMode;
  }

  void _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    setState(() {
      _version = version;
    });
  }

  void sendTestNotification() {
    StadsGradesProvider().SendGradeNotification("TEST NOTIFICATION");
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
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
                                  autoFetchEnabled = value!;
                                },
                              )
                            },
                          )
                        ]),
                    Container(
                      child: Row(
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
                                  },
                                )
                              },
                            ))
                          ]),
                    ),
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
                        Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      },
                                    )
                                  },
                                ),
                              ]),
                        ),
                        if (Foundation.kDebugMode) ...[
                          TextButton(
                              onPressed: sendTestNotification,
                              child: Text("Send Test Notification"))
                        ]
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
                            controlAffinity: ListTileControlAffinity.trailing,
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
                            controlAffinity: ListTileControlAffinity.trailing,
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
                            controlAffinity: ListTileControlAffinity.trailing,
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
                        Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () => {},
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              )),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () => {},
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(50, 30),
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Text(
                                "Open-Source Licenses",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              )),
                        )
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
