import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Privacy & Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.lock_outline,
                  color: Colors.green,
                ),
                title: const Text('Change Password'),
                subtitle: const Text(
                  'Send a password reset email',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () async {
                  if (user?.email == null) {
                    _showMessage(
                      context,
                      'No email address is associated with this account.',
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: user!.email!,
                    );

                    if (!context.mounted) return;

                    _showMessage(
                      context,
                      'Password reset email sent.',
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;

                    _showMessage(
                      context,
                      e.message ??
                          'Unable to send password reset email.',
                    );
                  }
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                  color: Colors.green,
                ),
                title: const Text('Email Address'),
                subtitle: Text(
                  user?.email ?? 'No email address',
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Privacy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.green,
                ),
                title: const Text('Your Privacy'),
                subtitle: const Text(
                  'Your account information is protected by Talon.',
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.green,
                ),
                title: const Text('Account Security'),
                subtitle: const Text(
                  'Talon uses Firebase Authentication to secure your account.',
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Account Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: Icon(
                  user?.emailVerified == true
                      ? Icons.verified
                      : Icons.warning_amber_outlined,
                  color: Colors.green,
                ),
                title: const Text('Email Verification'),
                subtitle: Text(
                  user?.emailVerified == true
                      ? 'Your email address is verified.'
                      : 'Your email address is not verified.',
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
