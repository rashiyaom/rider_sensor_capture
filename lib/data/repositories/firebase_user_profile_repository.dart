import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserProfileRepository {
  FirebaseUserProfileRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  static const collection = 'userProfiles';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      _firestore.collection(collection).doc(uid);

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snapshot = await _profileRef(user.uid).get();
    return snapshot.data();
  }

  Future<void> createProfileAndLinkPassword({
    required String name,
    required String email,
    required String password,
    required String ageBand,
    required String ridingExperience,
    required String vehicleDescription,
    required bool profileConsent,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.phoneNumber == null) {
      throw StateError('Verify your phone number before creating a profile.');
    }
    validateProfile(
      name: name,
      email: email,
      password: password,
      ageBand: ageBand,
      ridingExperience: ridingExperience,
      vehicleDescription: vehicleDescription,
      profileConsent: profileConsent,
    );

    // Linking keeps the phone-verified account UID stable. The password is
    // managed by Firebase Auth and is never written to Firestore.
    final normalizedEmail = email.trim().toLowerCase();
    final alreadyLinked =
        user.email?.toLowerCase() == normalizedEmail &&
        user.providerData.any((provider) => provider.providerId == 'password');
    if (!alreadyLinked) {
      await user.linkWithCredential(
        EmailAuthProvider.credential(
          email: normalizedEmail,
          password: password,
        ),
      );
    }
    await user.getIdToken(true);
    await user.updateDisplayName(name.trim());

    final profile = <String, Object?>{
      'uid': user.uid,
      'name': name.trim(),
      'email': normalizedEmail,
      'ageBand': ageBand,
      'ridingExperience': ridingExperience,
      'vehicleDescription': vehicleDescription.trim(),
      'profileConsent': true,
      'profileConsentVersion': 'profile-v1',
      'profileConsentedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _profileRef(user.uid).set(profile);
  }

  static const ageBands = <String>[
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55+',
    'Prefer not to say',
  ];

  static const ridingExperienceBands = <String>[
    'Less than 1 year',
    '1–3 years',
    '4–7 years',
    '8+ years',
    'Prefer not to say',
  ];

  static void validateProfile({
    required String name,
    required String email,
    required String password,
    required String ageBand,
    required String ridingExperience,
    required String vehicleDescription,
    required bool profileConsent,
  }) {
    if (!profileConsent) {
      throw StateError(
        'Consent to storing the participant profile is required.',
      );
    }
    if (name.trim().length < 2) {
      throw ArgumentError('Enter your name (at least 2 characters).');
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      throw ArgumentError('Enter a valid email address.');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must contain at least 8 characters.');
    }
    if (!ageBands.contains(ageBand)) {
      throw ArgumentError.value(ageBand, 'ageBand');
    }
    if (!ridingExperienceBands.contains(ridingExperience)) {
      throw ArgumentError.value(ridingExperience, 'ridingExperience');
    }
    if (vehicleDescription.trim().length < 2) {
      throw ArgumentError('Enter vehicle type or make/model.');
    }
  }
}
