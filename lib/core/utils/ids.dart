import 'package:uuid/uuid.dart';

/// Identifier factory, injected so tests can produce stable ids.
typedef IdFactory = String Function();

const _uuid = Uuid();

String newId() => _uuid.v4();
