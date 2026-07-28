
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
//The real values get created once, in main(), before the app starts, then dropped into these boxes via overrideWithValue.
//waits for the SharedPreferences instance to be opened in main() and then provides the instance to any provider that needs it. The provider is overridden in main() with the real SharedPreferences instance before runApp() is called, so any provider that reads it gets the already-opened instance rather than trying to open it lazily.
//empty placeholder boxes for something that takes time to set up (opening a database, reading device storage).
//remembering which filter chip was last selected.


final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'prefsProvider must be overridden in main.dart before runApp is called.',
  );
});
