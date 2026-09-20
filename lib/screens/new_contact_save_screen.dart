import 'package:flutter/material.dart';

class NewContactSaveScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String company;
  final String jobTitle;
  final String notes;

  const NewContactSaveScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.company,
    required this.jobTitle,
    required this.notes,
  });

  @override
  State<NewContactSaveScreen> createState() =>
      _NewContactSaveScreenState();
}

class _NewContactSaveScreenState extends State<NewContactSaveScreen> {
  void _saveContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Contact saved successfully."),
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
        title: const Text("Save Contact"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 20,
          ),

          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade200,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Review Contact",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Check the information before saving.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        "First Name: ${widget.firstName}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Last Name: ${widget.lastName}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      if (widget.email.isNotEmpty)
                        Text(
                          "Email: ${widget.email}",
                          style:
                              const TextStyle(fontSize: 16),
                        ),

                      if (widget.email.isNotEmpty)
                        const SizedBox(height: 10),

                      if (widget.phone.isNotEmpty)
                        Text(
                          "Phone: ${widget.phone}",
                          style:
                              const TextStyle(fontSize: 16),
                        ),

                      if (widget.phone.isNotEmpty)
                        const SizedBox(height: 10),

                      if (widget.company.isNotEmpty)
                        Text(
                          "Company: ${widget.company}",
                          style:
                              const TextStyle(fontSize: 16),
                        ),

                      if (widget.company.isNotEmpty)
                        const SizedBox(height: 10),

                      if (widget.jobTitle.isNotEmpty)
                        Text(
                          "Job Title: ${widget.jobTitle}",
                          style:
                              const TextStyle(fontSize: 16),
                        ),

                      if (widget.jobTitle.isNotEmpty)
                        const SizedBox(height: 10),

                      if (widget.notes.isNotEmpty)
                        Text(
                          "Notes: ${widget.notes}",
                          style:
                              const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: _saveContact,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    "Save Contact",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    side: const BorderSide(
                      color: Colors.green,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
