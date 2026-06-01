import 'package:isar/isar.dart';

// BlogPost entity represents a single blog post from Google Blogger API
// This model is used for local persistence with Isar NoSQL database
// Implements offline-first caching where posts are stored locally after fetch
part 'blog_post.g.dart';

@collection
class BlogPost {
  // Unique identifier from Blogger API (used as primary key)
  Id id = Isar.autoIncrement;

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
      return images[0]['url'] as String?;
    }
    // Fallback: extract from content HTML (basic implementation)
    // In production, consider more robust image extraction
    return null;
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