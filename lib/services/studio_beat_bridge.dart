import "package:flutter/foundation.dart";

class StudioBeatBridge {
  static final ValueNotifier<String?> selectedBeatId = ValueNotifier<String?>(
    null,
  );
  static void loadBeat(String id) {
    selectedBeatId.value = id;
  }

  static void clear() {
    selectedBeatId.value = null;
  }
}
