import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _auth.currentUser?.reload();

    if (!mounted) return;

    setState(() {
      _user = _auth.currentUser;
    });
  }

  String get _displayName {
    final name = _user?.displayName;

    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    final email = _user?.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Talon User';
  }

  String get _email {
    return _user?.email ?? 'No email available';
  }

  String get _firstName {
    final name = _displayName.trim();

    if (name.contains(' ')) {
      return name.split(' ').first;
    }

    return name;
  }

  String get _lastName {
    final name = _displayName.trim();

    if (name.contains(' ')) {
      final parts = name.split(' ');
      return parts.sublist(1).join(' ');
    }

    return 'Not added';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _editProfile() async {
    final nameController = TextEditingController(
      text: _displayName,
    );

    final phoneController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newName = nameController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name.'),
                    ),
                  );
                  return;
                }

                try {
                  final user = _auth.currentUser;

                  if (user == null) {
                    Navigator.pop(dialogContext, false);
                    _showMessage('No account found.');
                    return;
                  }

                  await user.updateDisplayName(newName);
                  await user.reload();

                  if (!mounted) return;

                  setState(() {
                    _user = _auth.currentUser;
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } on FirebaseAuthException catch (e) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, false);
                  }

                  _showMessage(
                    'Could not update profile: '
                    '${e.message ?? e.code}',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();

    if (saved == true) {
      _showMessage('Profile updated successfully.');
    }
  }

  // ============================================================
  // PROFILE DETAILS
  // ============================================================

  void _showProfileDetails() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Profile Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Name', _displayName),
              const SizedBox(height: 12),
              _detailRow('Email', _email),
              const SizedBox(height: 12),
              _detailRow(
                'Email Verified',
                _user?.emailVerified == true ? 'Yes' : 'No',
              ),
              const SizedBox(height: 12),
              _detailRow(
                'Account ID',
                _user?.uid ?? 'Unavailable',
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
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TalonSettingsScreen(),
      ),
    );
  }

  // ============================================================
  // LOG OUT
  // ============================================================

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out of Talon?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      _showMessage('Could not log out.');
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your Talon account? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _auth.currentUser?.delete();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showMessage(
          'For security, please log in again before deleting your account.',
        );
      } else {
        _showMessage(
          'Could not delete account: '
          '${e.message ?? e.code}',
        );
      }
    }
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT ITEM
  // ============================================================

  Widget _buildAccountItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 4,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Colors.green,
        ),
        title: Text(label),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // BUILD PROFILE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile'),
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

              const SizedBox(height: 12),

              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _email,
                style: const TextStyle(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _user?.emailVerified == true
                      ? 'Verified'
                      : 'Account',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildInfoRow(
                'First Name',
                _firstName,
              ),

              _buildInfoRow(
                'Last Name',
                _lastName,
              ),

              _buildInfoRow(
                'Email',
                _email,
              ),

              _buildInfoRow(
                'Phone',
                'Not added',
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildAccountItem(
                Icons.person,
                'Profile Details',
                _showProfileDetails,
              ),

              _buildAccountItem(
                Icons.settings,
                'Settings',
                _openSettings,
              ),

              _buildAccountItem(
                Icons.logout,
                'Log Out',
                _logout,
              ),

              _buildAccountItem(
                Icons.delete_outline,
                'Delete Account',
                _deleteAccount,
                iconColor: Colors.red,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TALON SETTINGS SCREEN
// ============================================================

class TalonSettingsScreen extends StatefulWidget {
  const TalonSettingsScreen({super.key});

  @override
  State<TalonSettingsScreen> createState() =>
      _TalonSettingsScreenState();
}

class _TalonSettingsScreenState
    extends State<TalonSettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _readReceipts = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _notifications =
          prefs.getBool('notifications') ?? true;

      _darkMode =
          prefs.getBool('dark_mode') ?? false;

      _readReceipts =
          prefs.getBool('read_receipts') ?? true;

      _language =
          prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveBool(
    String key,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveLanguage(
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // SETTINGS NAVIGATION
  // ============================================================

  void _openPrivacySecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PrivacySecurityScreen(),
      ),
    );
  }

  void _openLanguage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(
          currentLanguage: _language,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _language = result;
    });

    await _saveLanguage(result);
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HelpSupportScreen(),
      ),
    );
  }

  void _openAboutTalon() {
    showAboutDialog(
      context: context,
      applicationName: 'Talon',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Connect. Chat. Share.',
      applicationIcon: const Icon(
        Icons.chat_bubble_outline,
        color: Colors.green,
        size: 40,
      ),
      children: const [
        SizedBox(height: 12),
        Text(
          'Talon is a messaging application designed '
          'to help people connect, chat and share.',
        ),
      ],
    );
  }

  // ============================================================
  // SETTING CARD
  // ============================================================

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
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
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // BUILD SETTINGS
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _settingCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: _notifications
                    ? 'Notifications are enabled'
                    : 'Notifications are disabled',
                trailing: Switch(
                  value: _notifications,
                  activeThumbColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      _notifications = value;
                    });

                    await _saveBool(
                      'notifications',
                      value,
                    );

                    _showMessage(
                      value
                          ? 'Notifications enabled'
                          : 'Notifications disabled',
                    );
                  },
                ),
              ),

              _settingCard(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: _darkMode
                    ? 'Dark mode is enabled'
                    : 'Dark mode is disabled',
                trailing: Switch(
                  value: _darkMode,
                  activeThumbColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      _darkMode = value;
                    });

                    await _saveBool(
                      'dark_mode',
                      value,
                    );

                    _showMessage(
                      value
                          ? 'Dark mode enabled'
                          : 'Dark mode disabled',
                    );
                  },
                ),
              ),

              _settingCard(
                icon: Icons.done_all,
                title: 'Read Receipts',
                subtitle: _readReceipts
                    ? 'Read receipts are enabled'
                    : 'Read receipts are disabled',
                trailing: Switch(
                  value: _readReceipts,
                  activeThumbColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      _readReceipts = value;
                    });

                    await _saveBool(
                      'read_receipts',
                      value,
                    );

                    _showMessage(
                      value
                          ? 'Read receipts enabled'
                          : 'Read receipts disabled',
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _settingCard(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                subtitle:
                    'Manage your privacy and security',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _openPrivacySecurity,
              ),

              _settingCard(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _openLanguage,
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

              _settingCard(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle:
                    'Get help with using Talon',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _openHelpSupport,
              ),

              _settingCard(
                icon: Icons.info_outline,
                title: 'About Talon',
                subtitle: 'Version 1.0.0',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _openAboutTalon,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRIVACY & SECURITY
// ============================================================

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState
    extends State<PrivacySecurityScreen> {
  bool _profileVisibility = true;
  bool _onlineStatus = true;
  bool _readReceipts = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _profileVisibility =
          prefs.getBool('profile_visibility') ?? true;

      _onlineStatus =
          prefs.getBool('online_status') ?? true;

      _readReceipts =
          prefs.getBool('read_receipts') ?? true;
    });
  }

  Future<void> _saveBool(
    String key,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage(
        'No email address is associated with this account.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: user.email!,
      );

      _showMessage(
        'Password reset email sent to ${user.email}.',
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(
        'Could not send password reset email: '
        '${e.message ?? e.code}',
      );
    }
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<void> _emailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('No account found.');
      return;
    }

    await user.reload();

    final refreshedUser =
        FirebaseAuth.instance.currentUser;

    if (refreshedUser?.emailVerified == true) {
      _showMessage(
        'Your email is already verified.',
      );
      return;
    }

    try {
      await refreshedUser?.sendEmailVerification();

      _showMessage(
        'Verification email sent.',
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(
        'Could not send verification email: '
        '${e.message ?? e.code}',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.person_outline,
                color: Colors.green,
              ),
              title: const Text(
                'Profile Visibility',
              ),
              subtitle: const Text(
                'Allow other Talon users to see your profile',
              ),
              value: _profileVisibility,
              activeThumbColor: Colors.green,
              onChanged: (value) async {
                setState(() {
                  _profileVisibility = value;
                });

                await _saveBool(
                  'profile_visibility',
                  value,
                );
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.circle,
                color: Colors.green,
                size: 16,
              ),
              title: const Text(
                'Online Status',
              ),
              subtitle: const Text(
                'Show when you are online',
              ),
              value: _onlineStatus,
              activeThumbColor: Colors.green,
              onChanged: (value) async {
                setState(() {
                  _onlineStatus = value;
                });

                await _saveBool(
                  'online_status',
                  value,
                );
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.done_all,
                color: Colors.green,
              ),
              title: const Text(
                'Read Receipts',
              ),
              subtitle: const Text(
                'Allow others to see when you read messages',
              ),
              value: _readReceipts,
              activeThumbColor: Colors.green,
              onChanged: (value) async {
                setState(() {
                  _readReceipts = value;
                });

                await _saveBool(
                  'read_receipts',
                  value,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

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
                Icons.lock_reset,
                color: Colors.green,
              ),
              title: const Text(
                'Change Password',
              ),
              subtitle: const Text(
                'Send a password reset email',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: _changePassword,
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.verified_user_outlined,
                color: Colors.green,
              ),
              title: const Text(
                'Email Verification',
              ),
              subtitle: Text(
                user?.emailVerified == true
                    ? 'Your email is verified'
                    : 'Your email is not verified',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: _emailVerification,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================================
// LANGUAGE
// ============================================================

class LanguageScreen extends StatefulWidget {
  final String currentLanguage;

  const LanguageScreen({
    super.key,
    required this.currentLanguage,
  });

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState
    extends State<LanguageScreen> {
  late String _selectedLanguage;

  final List<String> _languages = [
    'English',
    'French',
    'Mauritian Creole',
  ];

  @override
  void initState() {
    super.initState();

    _selectedLanguage =
        widget.currentLanguage;
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Language set to $language',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          Navigator.pop(
            context,
            language,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: _languages.map(
                (language) {
                  final selected =
                      _selectedLanguage == language;

                  return ListTile(
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(language),
                    trailing: selected
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null,
                    onTap: () {
                      _selectLanguage(language);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELP & SUPPORT
// ============================================================

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showFaq(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Frequently Asked Questions',
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'How do I create an account?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create an account using your email '
                  'address and password.',
                ),
                SizedBox(height: 16),
                Text(
                  'How do I change my password?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Go to Settings → Privacy & Security → '
                  'Change Password.',
                ),
                SizedBox(height: 16),
                Text(
                  'How do I change my profile?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Open your Profile and select Edit Profile.',
                ),
                SizedBox(height: 16),
                Text(
                  'Is my account protected?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Talon uses Firebase Authentication to '
                  'secure user accounts.',
                ),
              ],
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

  void _reportProblem(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Report a Problem',
          ),
          content: TextField(
            controller: controller,
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
                controller.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final message =
                    controller.text.trim();

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please describe the problem.',
                      ),
                    ),
                  );
                  return;
                }

                controller.dispose();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Problem report recorded. Thank you.',
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Contact Support',
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'For support, please contact the Talon '
                'support team.',
              ),
              SizedBox(height: 16),
              Text(
                'Support email:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'support@talon.app',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Help & Support',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Find answers or get assistance with Talon.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.question_answer_outlined,
                color: Colors.green,
              ),
              title: const Text(
                'Frequently Asked Questions',
              ),
              subtitle: const Text(
                'Find answers to common questions',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                _showFaq(context);
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.bug_report_outlined,
                color: Colors.green,
              ),
              title: const Text(
                'Report a Problem',
              ),
              subtitle: const Text(
                'Report an issue with Talon',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                _reportProblem(context);
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: Colors.green,
              ),
              title: const Text(
                'Contact Support',
              ),
              subtitle: const Text(
                'Get in touch with Talon support',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                _contactSupport(context);
              },
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'Talon 1.0.0',
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}