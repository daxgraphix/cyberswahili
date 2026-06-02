import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_post.dart';

/// Provider for search state and results
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

/// Search state model
class SearchState {
  final String query;
  final List<BlogPost> results;
  final bool isSearching;

  SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SearchState copyWith({String? query, List<BlogPost>? results, bool? isSearching}) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// Notifier for managing search state
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  void updateQuery(String query) {
    state = state.copyWith(query: query);
    if (query.isEmpty) {
      clearResults();
    }
  }

  void setResults(List<BlogPost> results) {
    state = state.copyWith(results: results, isSearching: false);
  }

  void setSearching(bool isSearching) {
    state = state.copyWith(isSearching: isSearching);
  }

  void clearResults() {
    state = SearchState(query: state.query);
  }

  void clearAll() {
    state = SearchState();
  }
}