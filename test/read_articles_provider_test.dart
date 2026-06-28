import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberswahili/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadArticlesNotifier', () {
    test('migrates legacy read article ids', () async {
      SharedPreferences.setMockInitialValues({
        'read_articles': ['a', 'b'],
      });

      final prefs = await SharedPreferences.getInstance();
      final notifier = ReadArticlesNotifier(prefs);

      expect(notifier.state.keys, containsAll(['a', 'b']));
      expect(notifier.isRead('a'), isTrue);
    });

    test('persists read timestamps', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ReadArticlesNotifier(prefs);
      final readAt = DateTime(2026, 6, 26, 9);

      await notifier.markAsRead('post-1', readAt: readAt);

      expect(notifier.readAt('post-1'), readAt);
      expect(
        prefs.getStringList('read_article_events'),
        contains('post-1|2026-06-26T09:00:00.000'),
      );
    });
  });
}
