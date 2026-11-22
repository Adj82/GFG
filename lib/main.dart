import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'data/local/local_store.dart';
import 'data/providers.dart';
import 'data/seed/seed.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_IN');

  // Firebase mode keeps no local copy and seeds nothing: the data is in
  // Firestore (see BACKEND.md). The store is still opened for small settings
  // such as the theme.
  if (kUseFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
    }
  }
  final store = await LocalStore.open();
  if (!kUseFirebase && !store.isSeeded) await Seed.run(store);

  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const SocietyApp(),
    ),
  );
}
