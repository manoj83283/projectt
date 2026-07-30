import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/provider_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ProviderProvider>()
          .getProfile();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<
        ProviderProvider,
        ThemeProvider,
        LanguageProvider>(
      builder: (
        context,
        providerData,
        themeProvider,
        languageProvider,
        child,
      ) {
        final provider =
            providerData.provider;

        return Scaffold(
          appBar: AppBar(
            title:
                const Text('Profile'),
          ),
          body: providerData.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .all(16),
                  child: Column(
                    children: [
                      // =====================
                      // PROFILE CARD
                      // =====================

                      Card(
                        elevation: 2,
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Theme.of(
                                  context,
                                ).primaryColor,
                                backgroundImage:
                                    provider?.profileImage !=
                                                null &&
                                            provider!
                                                .profileImage!
                                                .isNotEmpty
                                        ? NetworkImage(
                                            provider.profileImage!,
                                          )
                                        : null,
                                child: provider?.profileImage ==
                                            null ||
                                        provider!
                                            .profileImage!
                                            .isEmpty
                                    ? Text(
                                        (provider?.fullName ??
                                                'P')
                                            .substring(
                                          0,
                                          1,
                                        )
                                            .toUpperCase(),
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              32,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              Text(
                                provider?.fullName ??
                                    'Provider',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      22,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                provider?.email ??
                                    '',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                provider?.phone ??
                                    '',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =====================
                      // ACCOUNT
                      // =====================

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  const Icon(
                                Icons.person,
                              ),
                              title:
                                  const Text(
                                'Edit Profile',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {},
                            ),
                            const Divider(
                              height: 1,
                            ),
                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .business,
                              ),
                              title:
                                  const Text(
                                'Business Details',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {},
                            ),
                            const Divider(
                              height: 1,
                            ),
                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .verified,
                              ),
                              title:
                                  const Text(
                                'Verification Documents',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =====================
                      // APP SETTINGS
                      // =====================

                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: themeProvider
                                  .isDarkMode,
                              secondary:
                                  const Icon(
                                Icons
                                    .dark_mode,
                              ),
                              title:
                                  const Text(
                                'Dark Mode',
                              ),
                              onChanged:
                                  (_) async {
                                await themeProvider
                                    .toggleTheme();
                              },
                            ),
                            const Divider(
                              height: 1,
                            ),
                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .language,
                              ),
                              title:
                                  const Text(
                                'Language',
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
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                _showLanguageDialog(
                                  context,
                                  languageProvider,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =====================
                      // SUPPORT
                      // =====================

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  const Icon(
                                Icons.help,
                              ),
                              title:
                                  const Text(
                                'Help & Support',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                            const Divider(
                              height: 1,
                            ),
                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .privacy_tip,
                              ),
                              title:
                                  const Text(
                                'Privacy Policy',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                            const Divider(
                              height: 1,
                            ),
                            ListTile(
                              leading:
                                  const Icon(
                                Icons.info,
                              ),
                              title:
                                  const Text(
                                'About App',
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 55,
                        child:
                            ElevatedButton.icon(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.red,
                          ),
                          onPressed:
                              _logout,
                          icon: const Icon(
                            Icons.logout,
                            color:
                                Colors.white,
                          ),
                          label:
                              const Text(
                            'LOGOUT',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Text(
                        'EventEase Provider v1.0.0',
                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
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

                        if (context.mounted) {
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
}