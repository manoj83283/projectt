import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Photographer',
      'icon': Icons.camera_alt,
    },
    {
      'name': 'Catering',
      'icon': Icons.restaurant,
    },
    {
      'name': 'Decoration',
      'icon': Icons.celebration,
    },
    {
      'name': 'Makeup',
      'icon': Icons.face,
    },
    {
      'name': 'Resort',
      'icon': Icons.hotel,
    },
    {
      'name': 'DJ',
      'icon': Icons.music_note,
    },
  ];

  final List<Map<String, dynamic>> featuredServices = [
    {
      'title': 'Wedding Photography',
      'rating': 4.8,
      'price': '₹15,000',
    },
    {
      'title': 'Premium Catering',
      'rating': 4.7,
      'price': '₹25,000',
    },
    {
      'title': 'Event Decoration',
      'rating': 4.9,
      'price': '₹12,000',
    },
  ];

  Future<void> refreshData() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void _openRoute(
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;

      case 1:
        _openRoute(
          RouteConfig.search,
        );
        break;

      case 2:
        _openRoute(
          RouteConfig.cart,
        );
        break;

      case 3:
        _openRoute(
          RouteConfig.myOrders,
        );
        break;

      case 4:
        _openRoute(
          RouteConfig.profile,
        );
        break;
    }
  }

  void _openCategory(
    Map<String, dynamic> category,
  ) {
    _openRoute(
      RouteConfig.serviceList,
      arguments: {
        'category': category['name'],
      },
    );
  }

  void _openFeaturedService(
    Map<String, dynamic> service,
  ) {
    _openRoute(
      RouteConfig.serviceDetails,
      arguments: {
        'service': service,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),

      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================
                // HEADER
                // =================================

                Container(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  decoration: const BoxDecoration(
                    color: ThemeConfig.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        25,
                      ),
                      bottomRight: Radius.circular(
                        25,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          const Expanded(
                            child: Text(
                              'Hyderabad, Telangana',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(
                              40,
                            ),
                            onTap: () {
                              _openRoute(
                                RouteConfig.profile,
                              );
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // SEARCH

                      InkWell(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        onTap: () {
                          _openRoute(
                            RouteConfig.search,
                          );
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: const IgnorePointer(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search services...',
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================
                // BANNER
                // =================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    onTap: () {
                      _openRoute(
                        RouteConfig.serviceList,
                      );
                    },
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ThemeConfig.primaryColor,
                            Color(
                              0xFF42A5F5,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Book Your Event Services',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Photographers • Catering • Decoration • Halls',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // =================================
                // CATEGORIES
                // =================================

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final category = categories[index];

                      return Card(
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          onTap: () {
                            _openCategory(
                              category,
                            );
                          },
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'],
                                color: ThemeConfig.primaryColor,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                category['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // =================================
                // FEATURED SERVICES
                // =================================

                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Text(
                          'Featured Services',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _openRoute(
                          RouteConfig.serviceList,
                        );
                      },
                      child: const Text(
                        'View All',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: featuredServices.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final service = featuredServices[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        onTap: () {
                          _openFeaturedService(
                            service,
                          );
                        },
                        leading: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: ThemeConfig.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Icon(
                            Icons.business_center,
                            color: ThemeConfig.primaryColor,
                          ),
                        ),
                        title: Text(
                          service['title'],
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            Text(
                              ' ${service['rating']}',
                            ),
                          ],
                        ),
                        trailing: Text(
                          service['price'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),

      // =================================
      // BOTTOM NAVIGATION
      // =================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ThemeConfig.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list_alt,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}