import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String _phone = 'Not added';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _auth.currentUser?.reload();

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _user = _auth.currentUser;
      _phone = prefs.getString('profile_phone') ?? 'Not added';
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

    final phoneController = TextEditingController(
      text: _phone == 'Not added' ? '' : _phone,
    );

    await showDialog(
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
                  textCapitalization: TextCapitalization.words,
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
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newPhone = phoneController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name.'),
                    ),
                  );
                  return;
                }

                try {
                  await _auth.currentUser?.updateDisplayName(
                    newName,
                  );

                  final prefs =
                      await SharedPreferences.getInstance();

                  await prefs.setString(
                    'profile_phone',
                    newPhone,
                  );

                  await _auth.currentUser?.reload();

                  if (!mounted) return;

                  setState(() {
                    _user = _auth.currentUser;
                    _phone = newPhone.isEmpty
                        ? 'Not added'
                        : newPhone;
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  _showMessage(
                    'Profile updated successfully.',
                  );
                } on FirebaseAuthException catch (e) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
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
              _detailRow('Phone', _phone),
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
            color: Colors.grey,
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
        builder: (_) => const SettingsScreen(),
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
              child: const Text('Cancel'),
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
          builder: (_) => const LoginScreen(),
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
            'Are you sure you want to permanently delete '
            'your Talon account?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
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

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('profile_phone');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showMessage(
          'For security, please log in again before '
          'deleting your account.',
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
  // BUILD PROFILE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                    color: Colors.green.withValues(alpha: 0.12),
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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Personal Information',
                    style: theme.textTheme.titleLarge?.copyWith(
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
                  _phone,
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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account',
                    style: theme.textTheme.titleLarge?.copyWith(
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
      ),
    );
  }
}

// ============================================================
// SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _readReceipts = true;
  bool _profileVisibility = true;
  bool _onlineStatus = true;
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

      _profileVisibility =
          prefs.getBool('profile_visibility') ?? true;

      _onlineStatus =
          prefs.getBool('online_status') ?? true;

      _language =
          prefs.getString('language') ?? 'English';
    });
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
  // NOTIFICATIONS
  // ============================================================

  Future<void> _setNotifications(bool value) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setNotifications(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool('notifications', value);
    }

    if (!mounted) return;

    setState(() {
      _notifications = value;
    });

    _showMessage(
      value
          ? 'Notifications enabled.'
          : 'Notifications disabled.',
    );
  }

  // ============================================================
  // DARK MODE
  // ============================================================

  Future<void> _setDarkMode(bool value) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setDarkMode(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool('dark_mode', value);
    }

    if (!mounted) return;

    setState(() {
      _darkMode = value;
    });

    _showMessage(
      value
          ? 'Dark mode enabled.'
          : 'Light mode enabled.',
    );
  }

  // ============================================================
  // READ RECEIPTS
  // ============================================================

  Future<void> _setReadReceipts(bool value) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setReadReceipts(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool('read_receipts', value);
    }

    if (!mounted) return;

    setState(() {
      _readReceipts = value;
    });

    _showMessage(
      value
          ? 'Read receipts enabled.'
          : 'Read receipts disabled.',
    );
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

  Future<void> _selectLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              activeColor: Colors.green,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(
                    dialogContext,
                    value,
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('French'),
              value: 'French',
              groupValue: _language,
              activeColor: Colors.green,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(
                    dialogContext,
                    value,
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Mauritian Creole'),
              value: 'Mauritian Creole',
              groupValue: _language,
              activeColor: Colors.green,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(
                    dialogContext,
                    value,
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    final app = TalonApp.of(context);

    if (app != null) {
      await app.setLanguage(selected);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString('language', selected);
    }

    if (!mounted) return;

    setState(() {
      _language = selected;
    });

    _showMessage(
      'Language preference saved: $selected.',
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  void _openPrivacySecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacySecurityScreen(),
      ),
    );
  }

  // ============================================================
  // HELP
  // ============================================================

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Talon',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.chat_bubble_outline,
        color: Colors.green,
        size: 40,
      ),
      applicationLegalese: 'Connect. Chat. Share.',
      children: const [
        SizedBox(height: 16),
        Text(
          'Talon is a messaging application designed '
          'to help people connect, chat and share with others.',
        ),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
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
                onChanged: _setNotifications,
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
                onChanged: _setDarkMode,
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
                onChanged: _setReadReceipts,
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
              onTap: _selectLanguage,
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
              subtitle: 'Get help with using Talon',
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
              onTap: _showAbout,
            ),

            const SizedBox(height: 40),
          ],
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
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    final prefs =
        await SharedPreferences.getInstance();

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

  Future<void> _setProfileVisibility(
    bool value,
  ) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setProfileVisibility(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'profile_visibility',
        value,
      );
    }

    if (!mounted) return;

    setState(() {
      _profileVisibility = value;
    });

    _showMessage(
      value
          ? 'Profile is now visible.'
          : 'Profile visibility disabled.',
    );
  }

  Future<void> _setOnlineStatus(bool value) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setOnlineStatus(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'online_status',
        value,
      );
    }

    if (!mounted) return;

    setState(() {
      _onlineStatus = value;
    });

    _showMessage(
      value
          ? 'Online status enabled.'
          : 'Online status hidden.',
    );
  }

  Future<void> _setReadReceipts(bool value) async {
    final app = TalonApp.of(context);

    if (app != null) {
      await app.setReadReceipts(value);
    } else {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'read_receipts',
        value,
      );
    }

    if (!mounted) return;

    setState(() {
      _readReceipts = value;
    });

    _showMessage(
      value
          ? 'Read receipts enabled.'
          : 'Read receipts disabled.',
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final email =
        FirebaseAuth.instance.currentUser?.email;

    if (email == null) {
      _showMessage(
        'No email address is associated with this account.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      _showMessage(
        'Password reset email sent to $email.',
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(
        'Could not send reset email: '
        '${e.message ?? e.code}',
      );
    }
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<void> _verifyEmail() async {
    final user =
        FirebaseAuth.instance.currentUser;

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

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
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
              onChanged: _setProfileVisibility,
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
              onChanged: _setOnlineStatus,
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
              onChanged: _setReadReceipts,
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
              onTap: _verifyEmail,
            ),
          ),

          const SizedBox(height: 40),
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
                style: TextStyle(color: Colors.green),
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
          title: const Text('Report a Problem'),
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
              child: const Text('Cancel'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Problem report recorded. Thank you.',
                    ),
                    behavior: SnackBarBehavior.floating,
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
          title: const Text('Contact Support'),
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
                style: TextStyle(color: Colors.green),
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
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              onTap: () => _showFaq(context),
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
              onTap: () => _reportProblem(context),
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
              onTap: () => _contactSupport(context),
            ),
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'Talon 1.0.0',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
