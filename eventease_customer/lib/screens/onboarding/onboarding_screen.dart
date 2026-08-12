import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.event_available,
      'title': 'Book Event Services',
      'description':
          'Find photographers, decorators, catering, halls and more for your special events.',
    },
    {
      'icon': Icons.location_on,
      'title': 'Nearby Providers',
      'description':
          'Discover trusted service providers near your location with ratings and reviews.',
    },
    {
      'icon': Icons.chat,
      'title': 'Chat & Track',
      'description':
          'Chat with providers, track bookings and receive live updates instantly.',
    },
  ];

  void _nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration:
            const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        RouteConfig.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ==========================
            // TOP BAR
            // ==========================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteConfig.login,
                      );
                    },
                    child: const Text(
                      'Skip',
                    ),
                  ),
                ],
              ),
            ),

            // ==========================
            // PAGE VIEW
            // ==========================

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder:
                    (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration:
                              BoxDecoration(
                            color:
                                ThemeConfig
                                    .primaryColor
                                    .withValues(
                              alpha: 0.1,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              30,
                            ),
                          ),
                          child: Icon(
                            pages[index]['icon'],
                            color:
                                ThemeConfig
                                    .primaryColor,
                            size: 90,
                          ),
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        Text(
                          pages[index]
                              ['title'],
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          pages[index]
                              ['description'],
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==========================
            // INDICATORS
            // ==========================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) {
                  return AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 300,
                    ),
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 4,
                    ),
                    height: 10,
                    width:
                        currentPage == index
                            ? 30
                            : 10,
                    decoration:
                        BoxDecoration(
                      color:
                          currentPage ==
                                  index
                              ? ThemeConfig
                                  .primaryColor
                              : Colors.grey
                                  .shade300,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // ==========================
            // BUTTON
            // ==========================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    currentPage ==
                            pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}