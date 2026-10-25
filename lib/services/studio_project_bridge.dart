import "package:flutter/foundation.dart";

class StudioProjectBridge {
  static final ValueNotifier<int> openStudioRequest = ValueNotifier<int>(0);
  static final ValueNotifier<String?> selectedProjectId =
      ValueNotifier<String?>(null);

  static void openProject(String id) {
    selectedProjectId.value = id;
    openStudioRequest.value++;
  }
}
