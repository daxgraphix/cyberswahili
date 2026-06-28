import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

enum ConnectionStatus {
  online,
  offline,
  serverDown,
}

class ConnectivityNotifier extends StateNotifier<ConnectionStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(ConnectionStatus.online) {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    await _updateStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectionStatus.offline;
      return;
    }

    // Even if connected to a network, the internet/server might be unreachable
    final isServerUp = await _checkServerReachability();
    if (isServerUp) {
      state = ConnectionStatus.online;
    } else {
      state = ConnectionStatus.serverDown;
    }
  }

  Future<bool> _checkServerReachability() async {
    try {
      // Use a lightweight check, e.g., to Google or the Blogger API
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectionStatus>((ref) {
  return ConnectivityNotifier();
});
