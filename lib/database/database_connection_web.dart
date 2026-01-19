import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

/// Create a web database connection using IndexedDB
/// This is only used on web platforms (checked via kIsWeb in database.dart)
/// Note: Requires sql.js to be loaded in index.html
LazyDatabase createWebConnection() {
  return LazyDatabase(() async {
    // Use WebDatabase with IndexedDB for web platform
    // Database name will be stored in browser's IndexedDB
    // This requires sql.js to be available (loaded via CDN in index.html)
    return WebDatabase('jackedlog', logStatements: kDebugMode);
  });
}

