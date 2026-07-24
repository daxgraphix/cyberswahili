import 'package:isar_db/isar_db.dart';

// BlogPost entity represents a single blog post from Google Blogger API
// This model is used for local persistence with Isar NoSQL database
// Implements offline-first caching where posts are stored locally after fetch
part 'blog_post.g.dart';

@collection
class BlogPost {
  // Unique identifier from Blogger API (used as primary key)
  int id = 0; // Primary key for isar_db (community fork uses 0 for auto-increment)

  // Blogger post ID string for API matching
  @Index(unique: true)
  late String postId;

  // Title of the blog post in Swahili or English
  late String title;

  // Full HTML content of the post for native rendering
  late String content;

  // Canonical URL of the post for sharing and external links
  late String url;

  // Publication timestamp from Blogger API
  late DateTime published;

  // Last update timestamp for content versioning
  late DateTime updated;

  // Category labels as Swahili tags (e.g., #UsalamaMtandaoni, #AkiliBandia)
  late List<String> labels;

  // Thumbnail image URL for content cards display
  String? thumbnailUrl;

  // Author name from Blogger API
  String? author;

  // Indicates if the full content is cached locally
  bool isContentCached = false;

  // Constructor for creating new BlogPost instances
  BlogPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.url,
    required this.published,
    required this.updated,
    required this.labels,
    this.thumbnailUrl,
    this.author,
    this.isContentCached = false,
  });
  
  static const String _defaultImageUrl = 'https://cyberswahili.blogspot.com';

  // Factory method to create BlogPost from Blogger API JSON response
  // Maps API fields to local entity structure
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    // Blogger API v3: published/updated are plain ISO-8601 strings
    return BlogPost(
      postId: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      url: json['url'] as String,
      published: DateTime.parse(json['published'] as String),
      updated: DateTime.parse(json['updated'] as String),
      labels: (json['labels'] as List<dynamic>?)?.cast<String>() ?? [],
      thumbnailUrl: _extractThumbnailUrl(json),
      author: (json['author'] as Map<String, dynamic>?)?['displayName'] as String?,
    );
  }

  // Helper method to extract thumbnail URL from Blogger post images
  // Looks for featured image in the post's media or content
  static String? _extractThumbnailUrl(Map<String, dynamic> json) {
    // Try to get from images array if available
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final firstImage = images[0];
      if (firstImage is Map<String, dynamic>) {
        final url = firstImage['url'] as String?;
        if (url != null && url.isNotEmpty) return url;
      }
    }
    
    // Try to get from post's author/profile image
    final author = json['author'] as Map<String, dynamic>?;
    if (author != null) {
      final displayName = author['displayName'] as String?;
      if (displayName != null && displayName.isNotEmpty) {
        return 'https://www.google.com/s2/photos/s120_c/${Uri.encodeComponent(displayName)}';
      }
    }
    
    // Fallback: extract first image from content HTML
    final content = json['content'] as String?;
    if (content != null) {
      final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"');
      final match = imgRegex.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    
    // Return default fallback
    return _defaultImageUrl;
  }

  // Convert BlogPost to JSON for API serialization if needed
  Map<String, dynamic> toJson() {
    return {
      'id': postId,
      'title': title,
      'content': content,
      'url': url,
      'published': published.toIso8601String(),
      'updated': updated.toIso8601String(),
      'labels': labels,
      'author': {'displayName': author},
      if (thumbnailUrl != null) 'images': [{'url': thumbnailUrl}],
    };
  }
}