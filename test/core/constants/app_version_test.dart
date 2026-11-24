import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/constants/app_version.dart';

void main() {
  group('AppVersion Configuration Tests', () {
    test('default version properties are correctly resolved', () {
      expect(AppVersion.current, isNotEmpty);
      expect(AppVersion.tag, startsWith('v'));
      expect(AppVersion.tag, contains(AppVersion.raw));
      expect(AppVersion.display, contains(AppVersion.tag));
      expect(AppVersion.display, contains('Ilmiya SIS'));
    });

    test('raw returns clean semantic string without v prefix', () {
      expect(AppVersion.raw.startsWith('v'), isFalse);
      expect(AppVersion.tag, 'v${AppVersion.raw}');
    });
  });
}
