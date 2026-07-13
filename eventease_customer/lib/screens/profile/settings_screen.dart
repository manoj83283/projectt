import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool darkMode = false;
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;

  String selectedLanguage = "English";

  final List<String> languages = [
    "English",
    "Hindi",
    "Telugu",
    "Tamil",
    "Kannada",
    "Malayalam",
    "Marathi",
    "Bengali",
  ];

  Future<void> _selectLanguage() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  languages[index],
                ),
                trailing:
                    selectedLanguage ==
                            languages[index]
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null,
                onTap: () {
                  setState(() {
                    selectedLanguage =
                        languages[index];
                  });

                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Logout",
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteConfig.login,
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Account",
          ),
          content: const Text(
            "This action cannot be undone. Do you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Delete account API integration pending",
                    ),
                  ),
                );
              },
              child: const Text(
                "Delete",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          "Settings",
        ),
      ),

      body: ListView(
        children: [
          // ======================
          // APP SETTINGS
          // ======================

          sectionTitle("App Settings"),

          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: darkMode,
                  title: const Text(
                    "Dark Mode",
                  ),
                  secondary: const Icon(
                    Icons.dark_mode,
                  ),
                  onChanged: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.language,
                  ),
                  title: const Text(
                    "Language",
                  ),
                  subtitle: Text(
                    selectedLanguage,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: _selectLanguage,
                ),
              ],
            ),
          ),

          // ======================
          // NOTIFICATIONS
          // ======================

          sectionTitle(
            "Notification Settings",
          ),

          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value:
                      pushNotifications,
                  title: const Text(
                    "Push Notifications",
                  ),
                  secondary: const Icon(
                    Icons.notifications,
                  ),
                  onChanged: (value) {
                    setState(() {
                      pushNotifications =
                          value;
                    });
                  },
                ),

                SwitchListTile(
                  value:
                      emailNotifications,
                  title: const Text(
                    "Email Notifications",
                  ),
                  secondary: const Icon(
                    Icons.email,
                  ),
                  onChanged: (value) {
                    setState(() {
                      emailNotifications =
                          value;
                    });
                  },
                ),

                SwitchListTile(
                  value: smsNotifications,
                  title: const Text(
                    "SMS Notifications",
                  ),
                  secondary: const Icon(
                    Icons.sms,
                  ),
                  onChanged: (value) {
                    setState(() {
                      smsNotifications =
                          value;
                    });
                  },
                ),
              ],
            ),
          ),

          // ======================
          // SECURITY
          // ======================

          sectionTitle("Security"),

          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.lock,
                  ),
                  title: const Text(
                    "Change Password",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {},
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.security,
                  ),
                  title: const Text(
                    "Privacy Policy",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {},
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.description,
                  ),
                  title: const Text(
                    "Terms & Conditions",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ======================
          // ACCOUNT
          // ======================

          sectionTitle("Account"),

          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  title: const Text(
                    "Delete Account",
                  ),
                  onTap: deleteAccount,
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    "Logout",
                  ),
                  onTap: logout,
                ),
              ],
            ),
          ),

          // ======================
          // VERSION
          // ======================

          Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: const [
                Icon(
                  Icons.event_available,
                  size: 50,
                  color:
                      ThemeConfig.primaryColor,
                ),
                SizedBox(height: 10),
                Text(
                  "EventEase",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}