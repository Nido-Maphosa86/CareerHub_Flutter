// lib/services/application_hub_service.dart
//
// Wraps a SignalR HubConnection to the CareerHub API's applications hub.
// This is additive, not load-bearing: /applications already works via
// getApplications() + pull-to-refresh without this connection ever
// succeeding. If the hub is unreachable (not yet implemented on the API, or
// a genuine network failure), connect() logs the failure and returns —
// it never throws, so a missing/broken hub can never crash the app or the
// screen that watches it.

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../config/app_config.dart';

class ApplicationHubService {
  HubConnection? _connection;

  Future<void> connect(VoidCallback onApplicationUpdated) async {
    final connection = HubConnectionBuilder()
        .withUrl('${AppConfig.apiBaseUrl}/hubs/applications')
        .withAutomaticReconnect()
        .build();

    connection.on('ApplicationStatusUpdated', (_) => onApplicationUpdated());

    connection.onclose(({error}) {
      debugPrint('ApplicationHubService: connection closed ($error)');
    });

    connection.onreconnecting(({error}) {
      debugPrint('ApplicationHubService: reconnecting ($error)');
    });

    // Not part of the assignment's minimum required sequence, but needed to
    // answer Question 3's tunnel scenario correctly: automatic reconnect
    // re-establishes the socket but does not replay events missed while
    // disconnected, so a fresh fetch is required to reconcile state.
    connection.onreconnected(({connectionId}) {
      debugPrint('ApplicationHubService: reconnected ($connectionId)');
      onApplicationUpdated();
    });

    _connection = connection;

    try {
      await connection.start();
      debugPrint(
        'ApplicationHubService: connected to ${AppConfig.apiBaseUrl}/hubs/applications',
      );
    } catch (e) {
      debugPrint('ApplicationHubService: connection failed ($e)');
      debugPrint('ApplicationHubService: real-time updates are unavailable — '
          'falling back to pull-to-refresh.');
    }
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
