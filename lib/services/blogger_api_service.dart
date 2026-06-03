import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_post.dart';

class BloggerApiService {
  static const String _base = 'https://www.googleapis.com/blogger/v3';
  static const Duration _timeout = Duration(seconds: 12);

  final String apiKey;
  final String blogId;

  BloggerApiService({required this.apiKey, required this.blogId});

  Future<List<BlogPost>> fetchPosts({int maxResults = 20, String? pageToken}) async {
    final params = <String, String>{
      'key': apiKey,
      'maxResults': maxResults.toString(),
      'fetchBodies': 'false',
      'fetchImages': 'true',
      'status': 'live',
    };
    if (pageToken != null) params['pageToken'] = pageToken;

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final url = Uri.parse('$_base/blogs/$blogId/posts?$query');
    final data = await _get(url);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => BlogPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String? getNextPageToken(Map<String, dynamic> data) {
    return data['nextPageToken'] as String?;
  }

  Future<String> fetchPostContent(String postId) async {
    final url = Uri.parse(
      '$_base/blogs/$blogId/posts/$postId'
      '?key=$apiKey'
      '&fetchBodies=true',
    );
    final data = await _get(url);
    return data['content'] as String? ?? '';
  }

  Future<List<BlogPost>> fetchPostsByLabel(String label,
      {int maxResults = 50}) async {
    final url = Uri.parse(
      '$_base/blogs/$blogId/posts'
      '?key=$apiKey'
      '&maxResults=$maxResults'
      '&fetchBodies=false'
      '&fetchImages=true'
      '&labels=${Uri.encodeComponent(label)}'
      '&status=live',
    );
    final data = await _get(url);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => BlogPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _get(Uri url) async {
    try {
      final response = await http.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 403) {
        throw Exception('API key invalid or quota exceeded (403)');
      }
      if (response.statusCode == 404) {
        throw Exception('Blog not found — check BLOG_ID in .env (404)');
      }
      throw Exception('Server error ${response.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}