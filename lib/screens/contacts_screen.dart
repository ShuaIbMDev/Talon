import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Map<String, String>> _contacts = [
    {
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "phone": "+1 555-1234",
      "status": "Active",
    },
    {
      "name": "John Brown",
      "email": "john.brown@example.com",
      "phone": "+1 555-5678",
      "status": "Active",
    },
    {
      "name": "Sarah Williams",
      "email": "sarah.williams@example.com",
      "phone": "+1 555-8765",
      "status": "Active",
    },
    {
      "name": "Michael Lee",
      "email": "michael.lee@example.com",
      "phone": "+1 555-4321",
      "status": "Active",
    },
    {
      "name": "Emily Davis",
      "email": "emily.davis@example.com",
      "phone": "+1 555-2468",
      "status": "Active",
    },
    {
      "name": "Daniel Wilson",
      "email": "daniel.wilson@example.com",
      "phone": "+1 555-1357",
      "status": "Active",
    },
  ];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(int index) {
    final contactName = _contacts[index]["name"]!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Delete Contact?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete $contactName from your contacts?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _contacts.removeAt(index);
                });

                _showSnackBar(
                  "$contactName removed from contacts",
                );
              },
              child: const Text(
                "Delete",
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

  Widget _buildContactCard(
    Map<String, String> contact,
    int index,
  ) {
    final String name = contact["name"]!;
    final String email = contact["email"]!;
    final String phone = contact["phone"]!;
    final String status = contact["status"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact avatar
            CircleAvatar(
              radius: 27,
              backgroundColor: Colors.green.shade100,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Contact information
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 15,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black54,
              ),
              onSelected: (value) {
                if (value == "edit") {
                  _showSnackBar(
                    "Edit $name",
                  );
                } else if (value == "message") {
                  _showSnackBar(
                    "Message $name",
                  );
                } else if (value == "delete") {
                  _confirmDelete(index);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "message",
                  child: Row(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text("Message"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Contacts",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              _showSnackBar("Search contacts");
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black87,
            ),
            onPressed: () {
              _showSnackBar("Contacts menu");
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "My Contacts",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "${_contacts.length} ${_contacts.length == 1 ? 'contact' : 'contacts'}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: _contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "No contacts yet",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Add your first contact to get started.",
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            _contacts.length,
                        itemBuilder:
                            (context, index) {
                          return _buildContactCard(
                            _contacts[index],
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: "Add Contact",
        onPressed: () {
          _showSnackBar("Add contact");
        },
        child: const Icon(
          Icons.person_add_alt_1,
        ),
      ),
    );
  }
}
