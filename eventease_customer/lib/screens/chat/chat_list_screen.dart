import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> chats = [
    {
      "id": "1",
      "name": "RK Photography",
      "message":
          "Sure, we can cover the complete wedding event.",
      "time": "10:45 AM",
      "unread": 2,
      "online": true,
    },
    {
      "id": "2",
      "name": "Royal Decorators",
      "message":
          "Decoration setup will start tomorrow.",
      "time": "09:20 AM",
      "unread": 0,
      "online": false,
    },
    {
      "id": "3",
      "name": "Tasty Catering",
      "message":
          "Menu list has been shared.",
      "time": "Yesterday",
      "unread": 5,
      "online": true,
    },
    {
      "id": "4",
      "name": "DJ Beats",
      "message":
          "Sound check completed successfully.",
      "time": "Yesterday",
      "unread": 0,
      "online": false,
    },
  ];

  List<Map<String, dynamic>> filteredChats = [];

  @override
  void initState() {
    super.initState();
    filteredChats = chats;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshChats() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void searchChats(String value) {
    setState(() {
      filteredChats = chats.where((chat) {
        return chat['name']
                .toString()
                .toLowerCase()
                .contains(
                  value.toLowerCase(),
                ) ||
            chat['message']
                .toString()
                .toLowerCase()
                .contains(
                  value.toLowerCase(),
                );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Messages',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: refreshChats,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: TextField(
                controller:
                    searchController,
                onChanged:
                    searchChats,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Search chats...',
                  prefixIcon:
                      Icon(Icons.search),
                ),
              ),
            ),

            Expanded(
              child: filteredChats.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount:
                          filteredChats.length,
                      itemBuilder:
                          (context, index) {
                        final chat =
                            filteredChats[
                                index];

                        return Card(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          elevation: 0,
                          child: ListTile(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteConfig.chat,
                                arguments: chat,
                              );
                            },

                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      ThemeConfig
                                          .primaryColor,
                                  child: Text(
                                    chat['name']
                                        .toString()
                                        .substring(
                                          0,
                                          1,
                                        ),
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),

                                if (chat[
                                        'online'] ==
                                    true)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child:
                                        Container(
                                      height:
                                          14,
                                      width:
                                          14,
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .green,
                                        border:
                                            Border.all(
                                          color: Colors
                                              .white,
                                          width:
                                              2,
                                        ),
                                        shape: BoxShape
                                            .circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            title: Text(
                              chat['name'],
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            subtitle: Text(
                              chat['message'],
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),

                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  chat['time'],
                                  style:
                                      TextStyle(
                                    fontSize:
                                        12,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                if (chat[
                                        'unread'] >
                                    0)
                                  Container(
                                    height:
                                        22,
                                    width:
                                        22,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Colors.green,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    alignment:
                                        Alignment
                                            .center,
                                    child: Text(
                                      chat[
                                              'unread']
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        color: Colors
                                            .white,
                                        fontSize:
                                            11,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            ThemeConfig.primaryColor,
        onPressed: () {},
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 150),
        Icon(
          Icons.chat_bubble_outline,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No Conversations Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}