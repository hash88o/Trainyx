// Stub file for web platform to avoid importing sqlite3
// This file is only used as a conditional import target and should not be directly imported

import 'package:drift/drift.dart';

LazyDatabase _createNativeConnectionImpl() {
  throw UnsupportedError('Native database connection not supported on web');
}

