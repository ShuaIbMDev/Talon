import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFaq(
    BuildContext context,
    String question,
    String answer,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(question),
          content: Text(
            answer,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help with Talon?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'You can contact the Talon support team '
                'for assistance with your account, '
                'messages or application problems.',
                style: TextStyle(
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'support@talon.app',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportProblem(BuildContext context) {
    final problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report a Problem'),
          content: TextField(
            controller: problemController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Describe the problem you are experiencing...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                problemController.dispose();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final problem =
                    problemController.text.trim();

                if (problem.isEmpty) {
                  _showMessage(
                    context,
                    'Please describe the problem first.',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                problemController.dispose();

                _showMessage(
                  context,
                  'Problem report saved. Thank you.',
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAppInformation(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Talon',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.chat_bubble_outline,
        color: Colors.green,
        size: 40,
      ),
      applicationLegalese:
          'Connect. Chat. Share.',
      children: const [
        SizedBox(height: 16),
        Text(
          'Talon is a messaging application designed '
          'to help people connect, chat and share.',
        ),
      ],
    );
  }

  Widget _buildSupportItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Find answers, report problems or contact '
            'the Talon support team.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildSupportItem(
            context: context,
            icon: Icons.question_answer_outlined,
            title: 'Frequently Asked Questions',
            subtitle:
                'Find answers to common questions',
            onTap: () {
              _showFaq(
                context,
                'How do I create a Talon account?',
                'Open Talon and select Sign Up. '
                'Enter your name, email address and '
                'password, then complete the registration '
                'process.',
              );
            },
          ),

          _buildSupportItem(
            context: context,
            icon: Icons.lock_outline,
            title: 'Account & Security',
            subtitle:
                'Learn about account security',
            onTap: () {
              _showFaq(
                context,
                'How can I protect my account?',
                'Use a strong password and keep your '
                'account credentials private. You can '
                'also use the Privacy & Security section '
                'in Settings to manage security options.',
              );
            },
          ),

          _buildSupportItem(
            context: context,
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle:
                'Get in touch with the support team',
            onTap: () {
              _showContactSupport(context);
            },
          ),

          _buildSupportItem(
            context: context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle:
                'Tell us about an issue',
            onTap: () {
              _showReportProblem(context);
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Application',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildSupportItem(
            context: context,
            icon: Icons.info_outline,
            title: 'About Talon',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAppInformation(context);
            },
          ),

          _buildSupportItem(
            context: context,
            icon: Icons.content_copy_outlined,
            title: 'Copy App Version',
            subtitle:
                'Copy the current version number',
            onTap: () async {
              await Clipboard.setData(
                const ClipboardData(
                  text: 'Talon 1.0.0',
                ),
              );

              if (!context.mounted) return;

              _showMessage(
                context,
                'Version copied to clipboard.',
              );
            },
          ),

          const SizedBox(height: 40),

          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green,
                  size: 42,
                ),
                SizedBox(height: 8),
                Text(
                  'Talon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
