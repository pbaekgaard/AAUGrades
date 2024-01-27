import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  String? _version;
  String? _buildNumber;
  String? _buildSignature;
  String? _appName;
  String? _packageName;
  String? _installerStore;

  static List<DropdownMenuItem> autoFetchOptions = [
    DropdownMenuItem(
        child: Text("Every fifteen minutes"), value: "Every fifteen minutes"),
    DropdownMenuItem(child: Text("Every half hour"), value: "Every half hour"),
    DropdownMenuItem(child: Text("Every hour"), value: "Every hour"),
    DropdownMenuItem(
        child: Text("Every third hour"), value: "Every third hour"),
    DropdownMenuItem(
        child: Text("Every sixth hour"), value: "Every sixth hour"),
    DropdownMenuItem(
        child: Text("Every twelfth hour"), value: "Every twelfth hour"),
    DropdownMenuItem(child: Text("Every day"), value: "Every day"),
  ];

  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final buildSignature = packageInfo.buildSignature;
    final appName = packageInfo.appName;
    final packageName = packageInfo.packageName;
    final installerStore = packageInfo.installerStore;

    setState(() {
      _version = version;
      _buildNumber = buildNumber;
      _buildSignature = buildSignature;
      _appName = appName;
      _packageName = packageName;
      _installerStore = installerStore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 24),
            child: Text("Settings",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
              padding: EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Grade Updates",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).primaryColor, fontSize: 20)),
                  Column(
                    children: [
                      Container(
                        child: Row(
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
                      ),
                      Container(
                        child: Row(
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
                      ),
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
                                padding: EdgeInsetsDirectional.only(end: 14),
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
              )),
          Container(
              padding: EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notifications",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).primaryColor, fontSize: 20)),
                  Column(
                    children: [
                      Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              )
                            ]),
                      )
                    ],
                  )
                ],
              )),
          Container(
              padding: EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("About",
                      style: GoogleFonts.inter(
                          color: Theme.of(context).primaryColor, fontSize: 20)),
                  Column(
                    children: [
                      Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                "${_version ?? '-'}",
                                style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              )
                            ]),
                      )
                    ],
                  )
                ],
              )),
          TextButton(
              onPressed: () => {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.only(top: 12),
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              child: Text(
                "Privacy Policy",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onBackground),
              )),
          TextButton(
              onPressed: () => {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.only(top: 12),
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              child: Text(
                "Open-Source Licenses",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onBackground),
              )),
        ],
      ),
    );
  }
}
