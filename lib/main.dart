import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'data/local/local_store.dart';
import 'data/providers.dart';
import 'data/seed/seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_IN');

  // Backend phase: initialise Firebase here and drop the local store.
  final store = await LocalStore.open();
  if (!store.isSeeded) await Seed.run(store);

  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const SocietyApp(),
    ),
  );
}
