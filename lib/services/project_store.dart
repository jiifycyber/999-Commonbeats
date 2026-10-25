import "package:idb_shim/idb_browser.dart";

class StudioProject {
  final String id;
  final String name;
  final String genre;
  final String? beatId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StudioProject({
    required this.id,
    required this.name,
    required this.genre,
    this.beatId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  StudioProject copyWith({
    String? name,
    String? genre,
    String? beatId,
    String? status,
    DateTime? updatedAt,
  }) => StudioProject(
    id: id,
    name: name ?? this.name,
    genre: genre ?? this.genre,
    beatId: beatId ?? this.beatId,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    "id": id,
    "name": name,
    "genre": genre,
    "beatId": beatId,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
  static StudioProject? fromMap(dynamic value) {
    if (value is! Map) return null;
    try {
      return StudioProject(
        id: value["id"] as String,
        name: value["name"] as String,
        genre: value["genre"] as String,
        beatId: value["beatId"] as String?,
        status: value["status"] as String,
        createdAt: DateTime.parse(value["createdAt"] as String),
        updatedAt: DateTime.parse(value["updatedAt"] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

class ProjectStore {
  static const _databaseName = "999_common_beats_projects";
  static const _storeName = "projects";
  static Future<Database> _open() => idbFactoryBrowser.open(
    _databaseName,
    version: 1,
    onUpgradeNeeded: (event) {
      if (!event.database.objectStoreNames.contains(_storeName)) {
        event.database.createObjectStore(_storeName);
      }
    },
  );
  static Future<List<StudioProject>> listAll() async {
    final db = await _open();
    try {
      final tx = db.transaction(_storeName, idbModeReadOnly);
      final records = await tx.objectStore(_storeName).getAll();
      await tx.completed;
      return records
          .map(StudioProject.fromMap)
          .whereType<StudioProject>()
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } finally {
      db.close();
    }
  }

  static Future<void> save(StudioProject project) async {
    final db = await _open();
    try {
      final tx = db.transaction(_storeName, idbModeReadWrite);
      await tx.objectStore(_storeName).put(project.toMap(), project.id);
      await tx.completed;
    } finally {
      db.close();
    }
  }

  static Future<void> remove(String id) async {
    final db = await _open();
    try {
      final tx = db.transaction(_storeName, idbModeReadWrite);
      await tx.objectStore(_storeName).delete(id);
      await tx.completed;
    } finally {
      db.close();
    }
  }
}
