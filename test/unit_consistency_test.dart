import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Consistency Audit Tests', () {
    test('no raw hardcoded conversion constants exist in lib/ outside angular_units.dart', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
          .where((f) => !f.path.endsWith('angular_units.dart'))
          .toList();

      final violations = <String>[];

      // Patterns to flag:
      // Hardcoded '9.81' or '9.80665' or '57.295'
      final rawGravityPattern = RegExp(r'(?<![a-zA-Z0-9_])9\.81(?![0-9])');
      final rawDegreeRadPattern = RegExp(r'(?<![a-zA-Z0-9_])57\.29(?![0-9])|(?<![a-zA-Z0-9_])57\.3(?![0-9])');

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip comments
          if (line.trim().startsWith('//') || line.trim().startsWith('*')) continue;

          if (rawGravityPattern.hasMatch(line)) {
            violations.add('${file.path}:${i + 1} uses raw literal 9.81: "$line"');
          }
          if (rawDegreeRadPattern.hasMatch(line)) {
            violations.add('${file.path}:${i + 1} uses raw literal 57.3: "$line"');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Hardcoded physical conversion constants found outside angular_units.dart:\n${violations.join('\n')}',
      );
    });
  });
}
