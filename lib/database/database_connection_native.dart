import 'package:drift/drift.dart';

// Conditional imports - only import sqlite3 on non-web platforms (when dart.library.io is available)
import 'database_connection_io.dart'
    if (dart.library.html) 'database_connection_stub.dart';

LazyDatabase createNativeConnection() {
  return _createNativeConnectionImpl();
}

// Implementation that will be conditionally imported
// Stub implementation for web - will be replaced by conditional import
LazyDatabase _createNativeConnectionImpl() {
  throw UnsupportedError('Native database connection not supported on web');
}
