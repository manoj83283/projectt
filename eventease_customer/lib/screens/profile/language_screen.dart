import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState
    extends State<LanguageScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedLanguage = 'English';

  final List<Map<String, String>> languages = [
    {
      "name": "English",
      "code": "en",
    },
    {
      "name": "Hindi",
      "code": "hi",
    },
    {
      "name": "Telugu",
      "code": "te",
    },
    {
      "name": "Tamil",
      "code": "ta",
    },
    {
      "name": "Kannada",
      "code": "kn",
    },
    {
      "name": "Malayalam",
      "code": "ml",
    },
    {
      "name": "Marathi",
      "code": "mr",
    },
    {
      "name": "Bengali",
      "code": "bn",
    },
    {
      "name": "Gujarati",
      "code": "gu",
    },
    {
      "name": "Punjabi",
      "code": "pa",
    },
    {
      "name": "Odia",
      "code": "or",
    },
  ];

  late List<Map<String, String>>
      filteredLanguages;

  @override
  void initState() {
    super.initState();
    filteredLanguages = languages;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchLanguage(String value) {
    setState(() {
      filteredLanguages = languages
          .where(
            (language) => language['name']!
                .toLowerCase()
                .contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Future<void> saveLanguage() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          '$selectedLanguage selected successfully',
        ),
      ),
    );

    Navigator.pop(
      context,
      selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Select Language',
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  searchController,
              onChanged:
                  searchLanguage,
              decoration:
                  const InputDecoration(
                hintText:
                    'Search Language',
                prefixIcon:
                    Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount:
                  filteredLanguages.length,
              itemBuilder:
                  (context, index) {
                final language =
                    filteredLanguages[
                        index];

                final bool isSelected =
                    selectedLanguage ==
                        language['name'];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        language['code']!
                            .toUpperCase(),
                      ),
                    ),
                    title: Text(
                      language['name']!,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color:
                                Colors.green,
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

          Container(
            padding:
                const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveLanguage,
                icon: const Icon(
                  Icons.language,
                ),
                label: Text(
                  'Save $selectedLanguage',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}