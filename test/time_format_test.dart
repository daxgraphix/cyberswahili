import 'package:flutter_test/flutter_test.dart';
import 'package:cyberswahili/utils/time_format.dart';

void main() {
  group('formatRelativeTime', () {
    final now = DateTime(2026, 6, 26, 12);

    test('uses days below seven days (English)', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 3)), swahili: false, now: now),
        '3 days ago',
      );
    });

    test('uses weeks from seven to twenty nine days (English)', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 17)), swahili: false, now: now),
        '2 weeks ago',
      );
    });

    test('uses months at thirty days and above (English)', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 31)), swahili: false, now: now),
        '1 month ago',
      );
    });

    test('formats Swahili labels - days', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 1)), swahili: true, now: now),
        'Siku 1 iliyopita',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 3)), swahili: true, now: now),
        'Siku 3 zilizopita',
      );
    });

    test('formats Swahili labels - weeks', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 7)), swahili: true, now: now),
        'Wiki 1 iliyopita',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 14)), swahili: true, now: now),
        'Wiki 2 zilizopita',
      );
    });

    test('formats Swahili labels - months', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 30)), swahili: true, now: now),
        'Mwezi 1 uliopita',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 60)), swahili: true, now: now),
        'Miezi 2 iliyopita',
      );
    });
  });
}
