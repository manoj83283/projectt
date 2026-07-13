import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      "message":
          "Hello, I would like to know more about your photography package.",
      "isMe": true,
      "time": "09:30 AM",
    },
    {
      "message":
          "Sure, we provide Premium Wedding Photography and Videography services.",
      "isMe": false,
      "time": "09:31 AM",
    },
    {
      "message":
          "Can you share package details?",
      "isMe": true,
      "time": "09:32 AM",
    },
    {
      "message":
          "Yes, basic package starts from ₹15,000.",
      "isMe": false,
      "time": "09:33 AM",
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text =
        messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "message": text,
        "isMe": true,
        "time":
            "${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}",
      });
    });

    messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position
                .maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const providerName =
        "RK Photography";

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              child: Icon(
                Icons.person,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: const [
                  Text(
                    providerName,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Online",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.video_call,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:
                  scrollController,
              padding:
                  const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder:
                  (context, index) {
                final message =
                    messages[index];

                final bool isMe =
                    message['isMe'];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    constraints:
                        BoxConstraints(
                      maxWidth:
                          MediaQuery.of(
                                    context,
                                  ).size.width *
                              0.75,
                    ),
                    decoration:
                        BoxDecoration(
                      color: isMe
                          ? ThemeConfig
                              .primaryColor
                          : Colors.white,
                      borderRadius:
                          BorderRadius.only(
                        topLeft:
                            const Radius.circular(
                          16,
                        ),
                        topRight:
                            const Radius.circular(
                          16,
                        ),
                        bottomLeft:
                            Radius.circular(
                          isMe ? 16 : 0,
                        ),
                        bottomRight:
                            Radius.circular(
                          isMe ? 0 : 16,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          message['time'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe
                                ? Colors.white70
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // MESSAGE BOX

          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.attach_file,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller:
                          messageController,
                      textCapitalization:
                          TextCapitalization
                              .sentences,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Type message...",
                        filled: true,
                        fillColor:
                            Colors.grey.shade100,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor:
                        ThemeConfig.primaryColor,
                    child: IconButton(
                      onPressed:
                          sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}