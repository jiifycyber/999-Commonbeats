import "package:flutter/material.dart";

import "../services/beat_autosave.dart";
import "../services/project_store.dart";
import "../services/studio_project_bridge.dart";
import "../services/studio_beat_bridge.dart";

class ProjectsPro extends StatefulWidget {
  const ProjectsPro({super.key});
  @override
  State<ProjectsPro> createState() => _ProjectsProState();
}

class _ProjectsProState extends State<ProjectsPro> {
  static const bg = Color(0xFF050D1B);
  static const panelColor = Color(0xFF0A1930);
  static const cyan = Color(0xFF25EDFF);
  static const gold = Color(0xFFE2B84F);
  late Future<List<StudioProject>> future;
  final search = TextEditingController();
  String filter = "All";
  @override
  void initState() {
    super.initState();
    future = ProjectStore.listAll();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void refresh() => setState(() => future = ProjectStore.listAll());
  Future<void> createProject() async {
    final nameController = TextEditingController();
    String genre = "Hip-Hop";
    String? beatId;
    bool saving = false;
    try {
      final beats = await BeatAutosave.listAll();
      if (!mounted) return;
      beats.sort((a, b) => a.id.compareTo(b.id));
      final created = await showDialog<StudioProject>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, update) => AlertDialog(
            backgroundColor: panelColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: cyan),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW PROJECT",
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "999 COMMON BEATS | STUDIO PRO",
                  style: TextStyle(color: cyan, fontSize: 11),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PROJECT DETAILS",
                      style: TextStyle(
                        color: cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Project Name",
                        prefixIcon: Icon(Icons.music_note, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: genre,
                      dropdownColor: panelColor,
                      decoration: const InputDecoration(
                        labelText: "Genre",
                        prefixIcon: Icon(Icons.library_music, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                "Hip-Hop",
                                "Trap",
                                "R&B",
                                "Drill",
                                "Pop",
                                "Afro Fusion",
                                "Lo-Fi",
                                "Other",
                              ]
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                      onChanged: (v) => update(() => genre = v ?? genre),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "INSTRUMENTAL",
                      style: TextStyle(
                        color: cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: beatId ?? "",
                      isExpanded: true,
                      dropdownColor: panelColor,
                      decoration: const InputDecoration(
                        labelText: "Select Beat",
                        prefixIcon: Icon(Icons.graphic_eq, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: "",
                          child: Text("Empty Project - No Beat"),
                        ),
                        ...List.generate(
                          beats.length,
                          (i) => DropdownMenuItem(
                            value: beats[i].id,
                            child: Text("Beat ${i + 1}"),
                          ),
                        ),
                      ],
                      onChanged: (v) => update(
                        () => beatId = v == null || v.isEmpty ? null : v,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Projects can be created without a beat and edited later.",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text("CANCEL"),
              ),
              FilledButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        update(() => saving = true);
                        final now = DateTime.now();
                        final project = StudioProject(
                          id: now.microsecondsSinceEpoch.toString(),
                          name: name,
                          genre: genre,
                          beatId: beatId,
                          status: "In Progress",
                          createdAt: now,
                          updatedAt: now,
                        );
                        try {
                          await ProjectStore.save(project);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, project);
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            update(() => saving = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text("Project save failed: $e"),
                              ),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.add),
                label: const Text("CREATE & OPEN"),
              ),
            ],
          ),
        ),
      );
      if (created != null && mounted) {
        refresh();
        openProject(created);
      }
    } finally {
      nameController.dispose();
    }
  }

  Future<void> editProject(StudioProject project) async {
    final controller = TextEditingController(text: project.name);
    String genre = project.genre;
    String? beatId = project.beatId;
    try {
      final beats = await BeatAutosave.listAll();
      beats.sort((a, b) => a.id.compareTo(b.id));
      if (!mounted) return;
      final genres = [
        "Hip-Hop",
        "Trap",
        "R&B",
        "Drill",
        "Pop",
        "Afro Fusion",
        "Lo-Fi",
        "Other",
      ];
      if (!genres.contains(genre)) genres.add(genre);
      final ids = beats.map((b) => b.id).toSet();
      if (beatId != null && !ids.contains(beatId)) beatId = null;
      final result = await showDialog<StudioProject>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, update) => AlertDialog(
            backgroundColor: panelColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: cyan),
            ),
            title: const Row(
              children: [
                Icon(Icons.edit_note, color: gold),
                SizedBox(width: 10),
                Text(
                  "EDIT PROJECT",
                  style: TextStyle(color: gold, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: "Project Name",
                        prefixIcon: Icon(Icons.music_note, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: genre,
                      isExpanded: true,
                      dropdownColor: panelColor,
                      decoration: const InputDecoration(
                        labelText: "Genre",
                        prefixIcon: Icon(Icons.library_music, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                      items: genres
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => update(() => genre = v ?? genre),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: beatId ?? "",
                      isExpanded: true,
                      dropdownColor: panelColor,
                      decoration: const InputDecoration(
                        labelText: "Attached Beat",
                        prefixIcon: Icon(Icons.graphic_eq, color: cyan),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: "",
                          child: Text("No Beat Attached"),
                        ),
                        ...List.generate(
                          beats.length,
                          (i) => DropdownMenuItem(
                            value: beats[i].id,
                            child: Text("Beat ${i + 1}"),
                          ),
                        ),
                      ],
                      onChanged: (v) => update(
                        () => beatId = v == null || v.isEmpty ? null : v,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("CANCEL"),
              ),
              FilledButton.icon(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.pop(
                    dialogContext,
                    StudioProject(
                      id: project.id,
                      name: controller.text.trim(),
                      genre: genre,
                      beatId: beatId,
                      status: project.status,
                      createdAt: project.createdAt,
                      updatedAt: DateTime.now(),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("SAVE CHANGES"),
              ),
            ],
          ),
        ),
      );
      if (result != null) {
        await ProjectStore.save(result);
        if (mounted) refresh();
      }
    } finally {
      controller.dispose();
    }
  }

  void openProject(StudioProject project) {
    if (project.beatId != null) {
      StudioBeatBridge.loadBeat(project.beatId!);
    } else {
      StudioBeatBridge.clear();
    }
    StudioProjectBridge.openProject(project.id);
  }

  Widget outlinedPanel(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: panelColor,
      border: Border.all(color: cyan, width: 1.3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
  @override
  Widget build(BuildContext context) => Container(
    color: bg,
    child: FutureBuilder<List<StudioProject>>(
      future: future,
      builder: (context, snapshot) {
        final all = snapshot.data ?? <StudioProject>[];
        final items = all
            .where(
              (p) =>
                  (filter == "All" || p.status == filter) &&
                  p.name.toLowerCase().contains(search.text.toLowerCase()),
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "PROJECTS",
                    style: TextStyle(
                      color: gold,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: createProject,
                  icon: const Icon(Icons.add),
                  label: const Text("NEW"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: [
                outlinedPanel(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder, color: cyan),
                      Text(
                        "${all.length}",
                        style: const TextStyle(color: gold, fontSize: 26),
                      ),
                      const Text(
                        "TOTAL PROJECTS",
                        style: TextStyle(color: cyan, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                outlinedPanel(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, color: cyan),
                      Text(
                        "${all.where((p) => p.status == "In Progress").length}",
                        style: const TextStyle(color: gold, fontSize: 26),
                      ),
                      const Text(
                        "IN PROGRESS",
                        style: TextStyle(color: cyan, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: cyan),
                hintText: "Search projects",
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: ["All", "In Progress", "Completed", "Archived"]
                  .map(
                    (v) => ChoiceChip(
                      label: Text(v),
                      selected: filter == v,
                      onSelected: (_) => setState(() => filter = v),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            if (snapshot.hasError)
              Text(
                "Could not load projects: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(),
            if (items.isEmpty)
              outlinedPanel(
                Column(
                  children: [
                    const Icon(Icons.folder_open, color: cyan, size: 42),
                    const SizedBox(height: 10),
                    Text(
                      all.isEmpty
                          ? "Your studio starts here"
                          : "No matching projects",
                      style: const TextStyle(color: gold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Create a project to organize your productions.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton.icon(
                      onPressed: createProject,
                      icon: const Icon(Icons.add),
                      label: const Text("CREATE PROJECT"),
                    ),
                  ],
                ),
              )
            else
              ...items.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => openProject(p),
                    borderRadius: BorderRadius.circular(12),
                    child: outlinedPanel(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.graphic_eq, color: cyan),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == "Edit") {
                                    await editProject(p);
                                    return;
                                  } else if (v == "Delete") {
                                    await ProjectStore.remove(p.id);
                                  } else {
                                    await ProjectStore.save(
                                      p.copyWith(
                                        status: v,
                                        updatedAt: DateTime.now(),
                                      ),
                                    );
                                  }
                                  if (mounted) {
                                    refresh();
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: "Edit",
                                    child: ListTile(
                                      leading: Icon(Icons.edit, color: cyan),
                                      title: Text("Edit Project"),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "In Progress",
                                    child: Text("In Progress"),
                                  ),
                                  PopupMenuItem(
                                    value: "Completed",
                                    child: Text("Completed"),
                                  ),
                                  PopupMenuItem(
                                    value: "Archived",
                                    child: Text("Archive"),
                                  ),
                                  PopupMenuItem(
                                    value: "Delete",
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(p.genre, style: const TextStyle(color: gold)),
                          const SizedBox(height: 5),
                          Text(
                            "Updated ${p.updatedAt.toLocal()}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          Text(p.status, style: const TextStyle(color: cyan)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "999 COMMON BEATS • PROJECTS",
                style: TextStyle(color: cyan, fontSize: 10),
              ),
            ),
          ],
        );
      },
    ),
  );
}
