import "package:flutter/material.dart";

import "../services/beat_autosave.dart";

class AnalyticsPro extends StatefulWidget {
  const AnalyticsPro({super.key});
  @override
  State<AnalyticsPro> createState() => _AnalyticsProState();
}

class _AnalyticsProState extends State<AnalyticsPro> {
  static const bg = Color(0xFF050D1B);
  static const panel = Color(0xFF0A1930);
  static const cyan = Color(0xFF25EDFF);
  static const gold = Color(0xFFE2B84F);
  late Future<List<SavedBeat>> beatsFuture;
  @override
  void initState() {
    super.initState();
    beatsFuture = BeatAutosave.listAll();
  }

  void refresh() => setState(() => beatsFuture = BeatAutosave.listAll());
  Widget panelCard(
    String title,
    String value,
    IconData icon, {
    String note = "Awaiting recorded data",
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(color: cyan, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cyan, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: gold,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            note,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget section(String title, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: panel,
      border: Border.all(color: cyan, width: 1.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Container(
    color: bg,
    child: FutureBuilder<List<SavedBeat>>(
      future: beatsFuture,
      builder: (context, snapshot) {
        final beats = snapshot.data ?? const <SavedBeat>[];
        final totalBytes = beats.fold<int>(
          0,
          (sum, beat) => sum + beat.bytes.length,
        );
        final mb = (totalBytes / 1048576).toStringAsFixed(2);
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ANALYTICS PRO",
                        style: TextStyle(
                          color: gold,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "999 COMMON BEATS  /  PRODUCTION INTELLIGENCE",
                        style: TextStyle(color: cyan, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: refresh,
                  tooltip: "Refresh analytics",
                  icon: const Icon(Icons.refresh, color: cyan),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(color: cyan),
            if (snapshot.hasError)
              section(
                "LIBRARY STATUS",
                Text(
                  "Unable to load audio library: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width < 420 ? 2 : 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.12,
              children: [
                panelCard(
                  "AUDIO ASSETS",
                  snapshot.hasData ? "${beats.length}" : "--",
                  Icons.audio_file,
                  note: "Saved library records",
                ),
                panelCard(
                  "LIBRARY SIZE",
                  snapshot.hasData ? "$mb MB" : "--",
                  Icons.storage,
                  note: "Stored audio bytes",
                ),
                panelCard(
                  "PROJECTS",
                  "--",
                  Icons.folder_copy,
                  note: "Project tracking not connected",
                ),
                panelCard(
                  "SUCCESSFUL EXPORTS",
                  "--",
                  Icons.file_download_done,
                  note: "Export history not connected",
                ),
                panelCard(
                  "STUDIO TIME",
                  "--",
                  Icons.schedule,
                  note: "Session tracking not connected",
                ),
                panelCard(
                  "AI OPERATIONS",
                  "--",
                  Icons.auto_awesome,
                  note: "AI usage tracking not connected",
                ),
              ],
            ),
            const SizedBox(height: 16),
            section(
              "PRODUCTION ACTIVITY",
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.query_stats, color: gold, size: 36),
                  SizedBox(height: 8),
                  Text(
                    "Activity history will appear when project, session, and export events are recorded.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            section(
              "AUDIO LIBRARY",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.library_music, color: cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          snapshot.hasData
                              ? "${beats.length} saved audio assets"
                              : "Loading saved audio assets...",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.data_usage, color: cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          snapshot.hasData
                              ? "$mb MB currently stored in the browser library"
                              : "Storage measurement unavailable",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Beat names remain private library metadata; this dashboard does not upload audio.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            section(
              "EXPORT PERFORMANCE",
              const Row(
                children: [
                  Icon(Icons.pending_actions, color: gold, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Export engine and export history integration pending. No success rate is reported until exports are tracked and verified.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            section(
              "AUDIO QUALITY & SYSTEM HEALTH",
              const Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.graphic_eq, color: cyan),
                    title: Text(
                      "BPM, key and loudness",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Available after audio analysis is integrated",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  Divider(color: Color(0xFF23415B)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.settings_input_component, color: cyan),
                    title: Text(
                      "Hardware and audio engine",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Live device health checks not connected",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "999 COMMON BEATS  •  ANALYTICS PRO",
                  style: TextStyle(color: cyan, fontSize: 10, letterSpacing: 1),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
