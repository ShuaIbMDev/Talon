import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'new_message_screen.dart';
import '../widgets/talon_logo.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> _conversations = [
    {
      "name": "Jane Smith",
      "message": "Hey, are you available today?",
      "time": "2 min",
      "unread": 2,
    },
    {
      "name": "John Brown",
      "message": "Thanks for your help!",
      "time": "10 min",
      "unread": 1,
    },
    {
      "name": "Sarah Williams",
      "message": "See you tomorrow.",
      "time": "30 min",
      "unread": 0,
    },
    {
      "name": "Michael Lee",
      "message": "I sent the documents.",
      "time": "1 hr",
      "unread": 0,
    },
    {
      "name": "Emily Davis",
      "message": "Can we discuss this later?",
      "time": "2 hrs",
      "unread": 3,
    },
    {
      "name": "Daniel Wilson",
      "message": "Perfect, thank you.",
      "time": "Yesterday",
      "unread": 0,
    },
  ];

  List<Map<String, dynamic>> _filteredConversations = [];

  @override
  void initState() {
    super.initState();

    _filteredConversations = List.from(_conversations);
    _searchController.addListener(_filterMessages);
  }

  void _filterMessages() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredConversations = List.from(_conversations);
      } else {
        _filteredConversations = _conversations.where((conversation) {
          final name =
              conversation["name"].toString().toLowerCase();

          final message =
              conversation["message"].toString().toLowerCase();

          return name.contains(query) ||
              message.contains(query);
        }).toList();
      }
    });
  }

  void _openChat(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          contactName: name,
        ),
      ),
    );
  }

  void _openNewMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewMessageScreen(),
      ),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.done_all,
                    color: Colors.green,
                  ),
                  title: const Text("Mark all as read"),
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      for (final conversation in _conversations) {
                        conversation["unread"] = 0;
                      }

                      _filterMessages();
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text("Notification settings"),
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Notification settings selected"),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text("Clear conversations"),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClearConversations();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearConversations() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Clear conversations?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "This will remove all conversations from this screen.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  _conversations.clear();
                  _filteredConversations.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Conversations cleared"),
                  ),
                );
              },
              child: Text(
                "Clear",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConversationItem(
    Map<String, dynamic> conversation,
  ) {
    final String name = conversation["name"];
    final String message = conversation["message"];
    final String time = conversation["time"];
    final int unreadCount = conversation["unread"];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,      borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openChat(name),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green.shade100,
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: unreadCount > 0
                          ? Colors.green.shade700
                          : Colors.black45,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: screenWidth * 0.06,
        title: Row(
          children: [
            TalonLogo(
              size: 34,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            Text(
              "Messages",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: "Search messages",
            onPressed: () {
              FocusScope.of(context).requestFocus(
                FocusNode(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: "Message options",
            onPressed: _showMessageOptions,
          ),
          SizedBox(
            width: screenWidth * 0.02,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Your conversations",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Stay connected with your contacts.",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search messages",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.65), fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.green,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "Recent",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (_filteredConversations.isEmpty)
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 55,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No conversations found",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Try another search.",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._filteredConversations.map(
                  _buildConversationItem,
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: "New Message",
        elevation: 4,
        onPressed: _openNewMessage,
        child: const Icon(Icons.edit),
      ),
    );
  }
}














