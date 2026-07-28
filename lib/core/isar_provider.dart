
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
//if any code reads the provider before the real Isar instance has been placed into it."
//The real values get created once, in main(), before the app starts, then dropped into these boxes via overrideWithValue.
//waits for the isar database to be opened in main() and then provides the instance to any provider that needs it. The provider is overridden in main() with the real Isar instance before runApp() is called, so any provider that reads it gets the already-opened instance rather than trying to open it lazily.
//empty placeholder boxes for something that takes time to set up (opening a database, reading device storage).

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden in main.dart before runApp is called.',
  );
});

