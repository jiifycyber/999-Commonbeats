import "package:flutter/foundation.dart";

import "package:idb_shim/idb_browser.dart";

class SavedBeat {
  final String id;
  final String name;
  final Uint8List bytes;
  SavedBeat(this.id, this.name, this.bytes);
}

class SavedBeatInfo {
  final String id;
  final int sizeBytes;
  const SavedBeatInfo(this.id, this.sizeBytes);
}

class BeatAutosave {
  static final ValueNotifier<int> libraryRevision = ValueNotifier<int>(0);
  static const String _databaseName = "999_common_beats";
  static const String _storeName = "audio_library";
  static const String _latestKey = "latest";
  static Future<Database> _open() async {
    return idbFactoryBrowser.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(_storeName);
        }
      },
    );
  }

  static Future<void> save(String name, Uint8List bytes) async {
    final db = await _open();
    try {
      final transaction = db.transaction(_storeName, idbModeReadWrite);
      final store = transaction.objectStore(_storeName);
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await store.put({"id": id, "name": name, "bytes": bytes.toList()}, id);
      await store.put(id, _latestKey);
      await transaction.completed;
      libraryRevision.value++;
    } finally {
      db.close();
    }
  }

  static Future<List<String>> listBeatIds() async {
    final db = await _open();
    try {
      final transaction = db.transaction(_storeName, idbModeReadOnly);
      final ids = <String>[];
      await for (final cursor
          in transaction
              .objectStore(_storeName)
              .openKeyCursor(autoAdvance: true)) {
        final key = cursor.key;
        if (key is String && key != _latestKey) ids.add(key);
      }
      await transaction.completed;
      ids.sort();
      return ids;
    } finally {
      db.close();
    }
  }

  static Future<List<SavedBeat>> listAll() async {
    final db = await _open();
    try {
      final transaction = db.transaction(_storeName, idbModeReadOnly);
      final records = await transaction.objectStore(_storeName).getAll();
      await transaction.completed;
      final beats = <SavedBeat>[];
      for (final record in records) {
        if (record is! Map) continue;
        final id = record["id"];
        final name = record["name"];
        final bytes = record["bytes"];
        if (id is String && name is String && bytes is List) {
          beats.add(SavedBeat(id, name, Uint8List.fromList(bytes.cast<int>())));
        }
      }
      beats.sort((a, b) => b.id.compareTo(a.id));
      return beats;
    } finally {
      db.close();
    }
  }

  static Future<SavedBeat?> loadById(String beatId) async {
    final db = await _open();
    try {
      final transaction = db.transaction(_storeName, idbModeReadOnly);
      final record = await transaction
          .objectStore(_storeName)
          .getObject(beatId);
      await transaction.completed;
      if (record is! Map) return null;
      final id = record["id"];
      final name = record["name"];
      final bytes = record["bytes"];
      if (id is! String || name is! String || bytes is! List) return null;
      return SavedBeat(id, name, Uint8List.fromList(bytes.cast<int>()));
    } finally {
      db.close();
    }
  }

  static Future<SavedBeat?> restoreLatest() async {
    final db = await _open();
    try {
      final transaction = db.transaction(_storeName, idbModeReadOnly);
      final store = transaction.objectStore(_storeName);
      final latestId = await store.getObject(_latestKey);
      final record = latestId == null ? null : await store.getObject(latestId);
      await transaction.completed;
      if (record is! Map) return null;
      final name = record["name"];
      final bytes = record["bytes"];
      final id = record["id"];
      if (name is! String || id is! String || bytes is! List) {
        return null;
      }
      return SavedBeat(id, name, Uint8List.fromList(bytes.cast<int>()));
    } finally {
      db.close();
    }
  }
}
