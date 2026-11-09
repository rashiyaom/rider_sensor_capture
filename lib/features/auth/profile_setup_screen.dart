import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/firebase_user_profile_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _repository = FirebaseUserProfileRepository();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _vehicle = TextEditingController();
  String? _ageBand;
  String? _ridingExperience;
  String? _error;
  bool _busy = false;
  bool _profileConsent = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _vehicle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ageBand = _ageBand;
    final ridingExperience = _ridingExperience;
    if (ageBand == null || ridingExperience == null) {
      setState(() => _error = 'Choose an age band and riding experience.');
      return;
    }
    if (!_profileConsent) {
      setState(() => _error = 'Agree to profile storage before continuing.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repository.createProfileAndLinkPassword(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        ageBand: ageBand,
        ridingExperience: ridingExperience,
        vehicleDescription: _vehicle.text,
        profileConsent: _profileConsent,
      );
      // FirebaseAuthGate observes this user's profile document and opens the
      // app after the server confirms the profile write.
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = switch (error.code) {
            'email-already-in-use' =>
              'That email is already linked to another account.',
            'weak-password' =>
              'Choose a stronger password (at least 8 characters).',
            'provider-already-linked' =>
              'A password is already set for this account. Sign in with it.',
            _ => error.message ?? 'Could not create your account details.',
          };
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString().replaceFirst('ArgumentError: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Participant profile'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _busy ? null : FirebaseAuth.instance.signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Phone verified: $phone'),
                const SizedBox(height: 8),
                const Text(
                  'Complete your study profile and set a password for future sign-ins. '
                  'Use vehicle type or make/model only; do not enter a registration plate.',
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email (password sign-in and recovery)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _ageBand,
                  decoration: const InputDecoration(labelText: 'Age band'),
                  items: FirebaseUserProfileRepository.ageBands
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _ageBand = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _ridingExperience,
                  decoration: const InputDecoration(
                    labelText: 'Riding experience',
                  ),
                  items: FirebaseUserProfileRepository.ridingExperienceBands
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _ridingExperience = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _vehicle,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle type or make/model',
                    hintText: 'e.g. commuter motorcycle, 150 cc',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Set password (8 or more characters)',
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _profileConsent,
                  onChanged: _busy
                      ? null
                      : (value) =>
                            setState(() => _profileConsent = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to store my name, email, age band, riding experience, and vehicle description in the RideSense Firebase project for participant account and study-record management.',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save profile and password'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your profile is stored separately from ride event data. '
                  'Firebase Auth manages your password; the app does not store it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
