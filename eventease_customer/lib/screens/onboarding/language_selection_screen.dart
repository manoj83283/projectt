import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class LanguageSelectionScreen
    extends StatefulWidget {
  const LanguageSelectionScreen({
    super.key,
  });

  @override
  State<LanguageSelectionScreen>
      createState() =>
          _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<
        LanguageSelectionScreen> {
  String selectedLanguage = 'English';

  final List<Map<String, String>>
      languages = [
    {
      'name': 'English',
      'code': 'en',
      'native': 'English',
    },
    {
      'name': 'Hindi',
      'code': 'hi',
      'native': 'हिन्दी',
    },
    {
      'name': 'Telugu',
      'code': 'te',
      'native': 'తెలుగు',
    },
    {
      'name': 'Tamil',
      'code': 'ta',
      'native': 'தமிழ்',
    },
    {
      'name': 'Kannada',
      'code': 'kn',
      'native': 'ಕನ್ನಡ',
    },
    {
      'name': 'Malayalam',
      'code': 'ml',
      'native': 'മലയാളം',
    },
    {
      'name': 'Marathi',
      'code': 'mr',
      'native': 'मराठी',
    },
    {
      'name': 'Bengali',
      'code': 'bn',
      'native': 'বাংলা',
    },
  ];

  void _continue() {
    Navigator.pushReplacementNamed(
      context,
      RouteConfig.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Language',
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.language,
                  size: 80,
                  color:
                      ThemeConfig.primaryColor,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Choose Your Language',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Select your preferred language for the application',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: languages.length,
              itemBuilder:
                  (context, index) {
                final language =
                    languages[index];

                final isSelected =
                    selectedLanguage ==
                        language['name'];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  elevation:
                      isSelected ? 4 : 1,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? ThemeConfig
                              .primaryColor
                          : Colors
                              .transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          ThemeConfig
                              .primaryColor
                              .withOpacity(
                        0.1,
                      ),
                      child: Text(
                        language['code']!
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: ThemeConfig
                              .primaryColor,
                        ),
                      ),
                    ),
                    title: Text(
                      language['name']!,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      language['native']!,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedLanguage =
                            language['name']!;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _continue,
                child: Text(
                  'Continue ($selectedLanguage)',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}