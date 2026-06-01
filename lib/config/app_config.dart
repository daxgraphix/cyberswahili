import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for API keys and settings
class AppConfig {
  static String get bloggerApiKey {
    // Get from environment variables or secure storage
    return dotenv.env['BLOGGER_API_KEY'] ?? 'YOUR_BLOGGER_API_KEY';
  }

  static String get blogId {
    // Get from environment variables or secure storage
    return dotenv.env['BLOG_ID'] ?? 'YOUR_BLOG_ID';
  }

  static bool get isConfigured {
    return bloggerApiKey != 'YOUR_BLOGGER_API_KEY' &&
           blogId != 'YOUR_BLOG_ID';
  }
}