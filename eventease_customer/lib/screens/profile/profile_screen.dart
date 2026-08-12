import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const user = {
      'name': 'Manoj Kumar',
      'email': 'manoj@example.com',
      'phone': '+91 9876543210',
      'profileCompletion': 85,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======================================
            // PROFILE HEADER
            // ======================================

            Container(
              width: double.infinity,
              color: ThemeConfig.primaryColor,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user['name'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user['email'].toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user['phone'].toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ======================================
            // PROFILE COMPLETION
            // ======================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Profile Completion',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${user['profileCompletion']}%',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: 0.85,
                        minHeight: 8,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ======================================
            // MENU ITEMS
            // ======================================

            _buildSection(
              title: 'Account',
              children: [
                _menuTile(
                  context,
                  Icons.edit,
                  'Edit Profile',
                  () {},
                ),
                _menuTile(
                  context,
                  Icons.event,
                  'My Bookings',
                  () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig.myBookings,
                    );
                  },
                ),
                _menuTile(
                  context,
                  Icons.shopping_bag,
                  'My Orders',
                  () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig.myOrders,
                    );
                  },
                ),
                _menuTile(
                  context,
                  Icons.star,
                  'My Reviews',
                  () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig.reviews,
                    );
                  },
                ),
                _menuTile(
                  context,
                  Icons.location_on,
                  'Saved Addresses',
                  () {},
                ),
              ],
            ),

            _buildSection(
              title: 'Preferences',
              children: [
                _menuTile(
                  context,
                  Icons.notifications,
                  'Notifications',
                  () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig.notifications,
                    );
                  },
                ),
                _menuTile(
                  context,
                  Icons.language,
                  'Language',
                  () {},
                ),
                _menuTile(
                  context,
                  Icons.security,
                  'Privacy & Security',
                  () {},
                ),
              ],
            ),

            _buildSection(
              title: 'Support',
              children: [
                _menuTile(
                  context,
                  Icons.help,
                  'Help & Support',
                  () {},
                ),
                _menuTile(
                  context,
                  Icons.info,
                  'About App',
                  () {},
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context);
                              },
                              child:
                                  const Text(
                                'Cancel',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context);

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  RouteConfig.login,
                                  (route) =>
                                      false,
                                );
                              },
                              child:
                                  const Text(
                                'Logout',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            ThemeConfig.primaryColor,
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}