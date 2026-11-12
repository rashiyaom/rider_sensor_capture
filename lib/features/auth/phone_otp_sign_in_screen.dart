import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PhoneOtpSignInScreen extends StatefulWidget {
  const PhoneOtpSignInScreen({super.key});

  @override
  State<PhoneOtpSignInScreen> createState() => _PhoneOtpSignInScreenState();
}

class _PhoneOtpSignInScreenState extends State<PhoneOtpSignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _email = TextEditingController(text: 'rashiyaom@gmail.com');
  final _password = TextEditingController();
  String? _verificationId;
  String? _error;
  bool _busy = false;
  bool _passwordMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInWithPassword() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error =
              error.message ??
              'Could not sign in with that email and password.';
        });
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Password reset email sent to $email.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message ?? 'Could not send the password reset email.';
        });
      }
    }
  }

  Future<void> _requestCode() async {
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      setState(() => _error = 'Enter the number with country code, e.g. +91…');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: _signIn,
        verificationFailed: (error) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _error = error.message ?? 'Could not send a verification code.';
          });
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _busy = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (mounted) setState(() => _verificationId = verificationId);
        },
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message ?? 'Could not start phone verification.';
        });
      }
    }
  }

  Future<void> _submitCode() async {
    final verificationId = _verificationId;
    final smsCode = _code.text.trim();
    if (verificationId == null || !RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      setState(() => _error = 'Enter the six-digit code from the SMS.');
      return;
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _signIn(credential);
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    if (mounted) {
      setState(() {
        _busy = true;
        _error = null;
      });
    }
    try {
      await _auth.signInWithCredential(credential);
      // The app's auth-state gate switches to the ride UI after success.
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message ?? 'The verification code was not accepted.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final awaitingCode = _verificationId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.two_wheeler,
                    size: 54,
                    color: AppColors.primaryWhite,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to RideSense',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your account keeps your driver contributions separate and lets you share reviewed road events.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_passwordMode) ...[
                    TextField(
                      key: const ValueKey('password-sign-in-email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('password-sign-in-password'),
                      controller: _password,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _sendPasswordReset,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  ] else if (!awaitingCode)
                    TextField(
                      key: const ValueKey('phone-sign-in-number'),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        hintText: '+919876543210',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                    )
                  else ...[
                    Text('Verification code sent to ${_phone.text.trim()}'),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('phone-sign-in-code'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Six-digit verification code',
                        prefixIcon: Icon(Icons.sms_outlined),
                      ),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _verificationId = null),
                      child: const Text('Change phone number'),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : _passwordMode
                        ? _signInWithPassword
                        : awaitingCode
                        ? _submitCode
                        : _requestCode,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _passwordMode
                                ? 'Sign in with password'
                                : awaitingCode
                                ? 'Verify and sign in'
                                : 'Send verification code',
                          ),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _passwordMode = !_passwordMode;
                            _verificationId = null;
                            _error = null;
                          }),
                    child: Text(
                      _passwordMode
                          ? 'First sign-in? Verify your phone'
                          : 'Already set a password? Sign in with email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Firebase uses your number to verify sign-in and help prevent abuse. SMS charges may apply.',
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
      ),
    );
  }
}
