import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase exactly once.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Web-specific optimisations ──
  if (kIsWeb) {
    // Keep auth state across page refreshes (indexedDB).
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

    // Enable Firestore local cache so repeated reads are instant.
    // `persistentCacheIndexManager` is only available with persistence; on web
    // the JS SDK uses IndexedDB automatically when multi-tab support is on.
    FirebaseFirestore.instance.settings = const Settings(
      // 40 MB cache — generous enough for a task app, avoids unbounded growth.
      cacheSizeBytes: 40 * 1024 * 1024,
      persistenceEnabled: true,
    );
  }

  runApp(
    const ProviderScope(
      child: UniTaskApp(),
    ),
  );
}