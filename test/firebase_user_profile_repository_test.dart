import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sensor_capture/data/repositories/firebase_user_profile_repository.dart';

void main() {
  group('FirebaseUserProfileRepository profile validation', () {
    void validate({
      String name = 'Test Rider',
      String email = 'rider@example.com',
      String password = 'long-enough-password',
      String ageBand = '25–34',
      String ridingExperience = '1–3 years',
      String vehicleDescription = '150 cc commuter motorcycle',
      bool profileConsent = true,
    }) => FirebaseUserProfileRepository.validateProfile(
      name: name,
      email: email,
      password: password,
      ageBand: ageBand,
      ridingExperience: ridingExperience,
      vehicleDescription: vehicleDescription,
      profileConsent: profileConsent,
    );

    test('accepts a complete participant profile', () {
      expect(validate, returnsNormally);
    });

    test('requires a name, valid email, and minimum password length', () {
      expect(() => validate(name: 'A'), throwsArgumentError);
      expect(() => validate(email: 'not-an-email'), throwsArgumentError);
      expect(() => validate(password: 'short'), throwsArgumentError);
    });

    test('accepts only declared age and riding-experience bands', () {
      expect(
        () => validate(ageBand: 'exact date of birth'),
        throwsArgumentError,
      );
      expect(() => validate(ridingExperience: 'unknown'), throwsArgumentError);
    });

    test('requires a vehicle description', () {
      expect(() => validate(vehicleDescription: ' '), throwsArgumentError);
    });

    test('requires explicit consent to store profile fields', () {
      expect(() => validate(profileConsent: false), throwsStateError);
    });
  });
}
