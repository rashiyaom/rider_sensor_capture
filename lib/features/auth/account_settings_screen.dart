import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      _showMessage(
        'This account does not have an email/password sign-in.',
        error: true,
      );
      return;
    }
    if (_newPassword.text.length < 8) {
      _showMessage(
        'New password must contain at least 8 characters.',
        error: true,
      );
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: _currentPassword.text,
        ),
      );
      await user.updatePassword(_newPassword.text);
      _currentPassword.clear();
      _newPassword.clear();
      _showMessage('Password changed.');
    } on FirebaseAuthException catch (error) {
      _showMessage(
        error.message ?? 'Could not change the password.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      _showMessage('This account has no recovery email.', error: true);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent to $email.');
    } on FirebaseAuthException catch (error) {
      _showMessage(
        error.message ?? 'Could not send a reset email.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: user == null
                      ? null
                      : FirebaseFirestore.instance
                            .collection('userProfiles')
                            .doc(user.uid)
                            .get(),
                  builder: (context, snapshot) {
                    final profile = snapshot.data?.data();
                    if (profile == null) return const SizedBox.shrink();
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['name'] as String? ?? 'Participant',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile['email'] as String? ?? user?.email ?? '',
                            ),
                            Text('Age band: ${profile['ageBand'] ?? '—'}'),
                            Text(
                              'Riding experience: ${profile['ridingExperience'] ?? '—'}',
                            ),
                            Text(
                              'Vehicle: ${profile['vehicleDescription'] ?? '—'}',
                            ),
                            Text('Phone: ${user?.phoneNumber ?? '—'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Change password',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPassword,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPassword,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'New password (8+ characters)',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _changePassword,
                  child: const Text('Change password'),
                ),
                TextButton(
                  onPressed: _busy ? null : _resetPassword,
                  child: const Text('Send password reset email'),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _isError
                          ? Colors.redAccent
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _busy ? null : FirebaseAuth.instance.signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
