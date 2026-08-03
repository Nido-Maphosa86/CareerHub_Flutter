// lib/providers/application_hub_provider.dart
//
// Plain Provider (no @riverpod, no code generation) — the service instance
// and its connection lifecycle are simple enough that generated boilerplate
// would add nothing. Watching this provider from ApplicationsScreen is what
// triggers connect(); disposing the provider (screen leaves the widget tree
// for good, or the ProviderScope is torn down) disconnects the socket.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/applications/providers/applications_notifier.dart';
import '../services/application_hub_service.dart';

final applicationHubProvider = Provider<ApplicationHubService>((ref) {
  final service = ApplicationHubService();

  service.connect(() => ref.invalidate(applicationsProvider));

  ref.onDispose(service.disconnect);

  return service;
});
