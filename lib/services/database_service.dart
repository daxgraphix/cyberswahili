import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/blog_post.dart';

// DatabaseService handles Isar database initialization and management
// Provides singleton access to the Isar instance for the entire app
// Ensures offline-first persistence for blog posts
class DatabaseService {
  // Singleton instance of Isar database
  static Isar? _isar;

  // Get the Isar instance, initializing it if necessary
  static Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    // Get application documents directory for database storage
    final dir = await getApplicationDocumentsDirectory();

    // Initialize Isar with BlogPost schema
    _isar = await Isar.open(
      [BlogPostSchema],
      directory: dir.path,
      name: 'cyberswahili_db',
    );

    return _isar!;
  }

  // Close the database when app is terminating
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}