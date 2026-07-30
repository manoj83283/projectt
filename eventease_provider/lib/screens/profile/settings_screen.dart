import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingNotifications = true;
  bool _paymentNotifications = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      await context
          .read<NotificationProvider>()
          .loadSettings();
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from EventEase?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await context
        .read<AuthProvider>()
        .logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showLanguageDialog(
    LanguageProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: LanguageProvider
                  .supportedLanguages
                  .entries
                  .map(
                    (entry) => ListTile(
                      title:
                          Text(entry.value),
                      trailing:
                          provider.languageCode ==
                                  entry.key
                              ? const Icon(
                                  Icons.check,
                                  color:
                                      Colors.green,
                                )
                              : null,
                      onTap: () async {
                        await provider
                            .changeLanguage(
                          entry.key,
                        );

                        if (mounted) {
                          Navigator.pop(
                            context,
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<
        ThemeProvider,
        LanguageProvider>(
      builder: (
        context,
        themeProvider,
        languageProvider,
        child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title:
                const Text('Settings'),
          ),
          body: ListView(
            children: [
              const SizedBox(height: 10),

              // =========================
              // APPEARANCE
              // =========================

              _sectionTitle(
                'Appearance',
              ),

              Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SwitchListTile(
                  value:
                      themeProvider.isDarkMode,
                  secondary:
                      const Icon(
                    Icons.dark_mode,
                  ),
                  title:
                      const Text(
                    'Dark Mode',
                  ),
                  subtitle:
                      const Text(
                    'Enable dark theme',
                  ),
                  onChanged: (_) async {
                    await themeProvider
                        .toggleTheme();
                  },
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // LANGUAGE
              // =========================

              _sectionTitle(
                'Language',
              ),

              Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.language,
                  ),
                  title:
                      const Text(
                    'Application Language',
                  ),
                  subtitle: Text(
                    languageProvider
                        .getLanguageName(
                      languageProvider
                          .languageCode,
                    ),
                  ),
                  trailing:
                      const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () =>
                      _showLanguageDialog(
                    languageProvider,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // NOTIFICATIONS
              // =========================

              _sectionTitle(
                'Notifications',
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
                          _pushNotifications,
                      secondary:
                          const Icon(
                        Icons
                            .notifications_active,
                      ),
                      title:
                          const Text(
                        'Push Notifications',
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          _pushNotifications =
                              value;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                    ),
                    SwitchListTile(
                      value:
                          _emailNotifications,
                      secondary:
                          const Icon(
                        Icons.email,
                      ),
                      title:
                          const Text(
                        'Email Notifications',
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          _emailNotifications =
                              value;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                    ),
                    SwitchListTile(
                      value:
                          _smsNotifications,
                      secondary:
                          const Icon(
                        Icons.sms,
                      ),
                      title:
                          const Text(
                        'SMS Notifications',
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          _smsNotifications =
                              value;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                    ),
                    SwitchListTile(
                      value:
                          _bookingNotifications,
                      secondary:
                          const Icon(
                        Icons.event,
                      ),
                      title:
                          const Text(
                        'Booking Alerts',
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          _bookingNotifications =
                              value;
                        });
                      },
                    ),
                    const Divider(
                      height: 1,
                    ),
                    SwitchListTile(
                      value:
                          _paymentNotifications,
                      secondary:
                          const Icon(
                        Icons.payments,
                      ),
                      title:
                          const Text(
                        'Payment Alerts',
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          _paymentNotifications =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // ACCOUNT
              // =========================

              _sectionTitle(
                'Account',
              ),

              Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.lock_reset,
                      ),
                      title: const Text(
                        'Change Password',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.verified_user,
                      ),
                      title: const Text(
                        'Verification Status',
                      ),
                      subtitle: const Text(
                        'View KYC & Documents',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.security,
                      ),
                      title: const Text(
                        'Privacy & Security',
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

              const SizedBox(height: 15),

              // =========================
              // SUPPORT
              // =========================

              _sectionTitle(
                'Support & Legal',
              ),

              Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.help_center,
                      ),
                      title: const Text(
                        'Help & Support',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.description,
                      ),
                      title: const Text(
                        'Terms & Conditions',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.privacy_tip,
                      ),
                      title: const Text(
                        'Privacy Policy',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const Divider(
                      height: 1,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                      ),
                      title: const Text(
                        'About EventEase',
                      ),
                      subtitle:
                          const Text(
                        'Version 1.0.0',
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

              const SizedBox(height: 24),

              // =========================
              // LOGOUT
              // =========================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SizedBox(
                  height: 55,
                  child:
                      ElevatedButton.icon(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.red,
                    ),
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color:
                          Colors.white,
                    ),
                    label: const Text(
                      'LOGOUT',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'EventEase Provider v1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}