import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _connectivity = Connectivity();

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return _connectivity.onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityStreamProvider);
  return result.when(
    data: (results) =>
        results.isEmpty || results.every((r) => r == ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
});
