import 'package:flutter/material.dart';
import 'chat_screen.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final List<Map<String, String>> _contacts = [
    {"name": "Jane Smith", "info": "jane.smith@example.com"},
    {"name": "John Brown", "info": "john.brown@example.com"},
    {"name": "Sarah Williams", "info": "sarah.williams@example.com"},
    {"name": "Michael Lee", "info": "michael.lee@example.com"},
    {"name": "Emily Davis", "info": "emily.davis@example.com"},
    {"name": "Daniel Wilson", "info": "daniel.wilson@example.com"},
  ];

  final List<Map<String, String>> _recent = [
    {"name": "Jane Smith", "info": "jane.smith@example.com"},
    {"name": "John Brown", "info": "john.brown@example.com"},
  ];

  void _openChat(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
  contactName: name,
  contactEmail: contact["info"],

)
        ),
      ),
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    final name = contact["name"]!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 4,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade200,
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(contact["info"]!),
        trailing: IconButton(
          icon: const Icon(
            Icons.message,
            color: Colors.green,
          ),
          onPressed: () => _openChat(name),
        ),
        onTap: () => _openChat(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Message"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  hintText: "Search contacts",
                  prefixIcon:
                      const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Recent",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Column(
                children: _recent
                    .map(
                      (contact) =>
                          _buildContactTile(contact),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              const Text(
                "Contacts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Column(
                children: _contacts
                    .map(
                      (contact) =>
                          _buildContactTile(contact),
                    )
                    .toList(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}