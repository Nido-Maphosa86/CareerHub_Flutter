import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//This is what powers your offline banner — two providers working together to answer one question: "does this device currently have internet?"


final _connectivity = Connectivity();//checks the device's network connectivity status and provides a stream of updates whenever the connectivity changes. It can detect whether the device is connected to Wi-Fi, mobile data, or has no internet connection at all.

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return _connectivity.onConnectivityChanged;
});


final isOfflineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityStreamProvider);
  return result.when(
    data: (results) =>
        results.isEmpty || results.every((r) => r == ConnectivityResult.none),
    loading: () => false,//while waiting for the very first reading (right at app start), assume online. This avoids incorrectly flashing the offline banner before a real reading has arrived.
    error: (_, __) => false,//if reading connectivity somehow failed, also default to assuming online.
  );
});
