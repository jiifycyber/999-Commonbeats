import "package:flutter/material.dart";

import "../widgets/studio/upload_panel.dart";
import "../widgets/studio/production_modes.dart";
import "../widgets/studio/beat_dna_panel.dart";
import "../widgets/studio/sound_mixer.dart";
import "../widgets/studio/compare_panel.dart";

class FuturisticStudio extends StatelessWidget {
  const FuturisticStudio({super.key});
  static const background = Color(0xFF070914);
  static const surface = Color(0xFF111329);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text(
          "999 COMMON BEATS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Chip(label: Text("STUDIO V2")),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1050;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AI BEAT PRODUCTION STUDIO",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create. Reconstruct. Enhance. Compare.",
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 155,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purpleAccent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    "assets/images/studio_banner.png",
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _ProductionWorkflow(),
              const SizedBox(height: 16),
              const UploadPanel(),
              const SizedBox(height: 20),
              if (wide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ProductionModes()),
                    SizedBox(width: 16),
                    Expanded(child: BeatDnaPanel()),
                  ],
                )
              else
                const Column(
                  children: [
                    ProductionModes(),
                    SizedBox(height: 16),
                    BeatDnaPanel(),
                  ],
                ),
              const SizedBox(height: 20),
              const _BeatVariationLibrary(),
              const SizedBox(height: 20),
              const SoundMixer(),
              const SizedBox(height: 20),
              const ComparePanel(),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "Audio generation and export engine: integration pending",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          );
          return Row(
            children: [
              if (wide) const _StudioSidebar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudioSidebar extends StatefulWidget {
  const _StudioSidebar();
  @override
  State<_StudioSidebar> createState() => _StudioSidebarState();
}

class _StudioSidebarState extends State<_StudioSidebar> {
  int selected = 0;
  static const labels = [
    "New Project",
    "Upload Beat",
    "Reconstruction Studio",
    "Enhancement Studio",
    "Beat DNA Lock",
    "Compare Beats",
    "Export & Save",
    "My Projects",
    "Sound Library",
    "AI Sound Packs",
    "Analytics",
    "Settings",
  ];
  static const icons = [
    Icons.add_box_outlined,
    Icons.upload_file,
    Icons.auto_awesome,
    Icons.tune,
    Icons.lock_outline,
    Icons.compare_arrows,
    Icons.file_upload_outlined,
    Icons.folder_outlined,
    Icons.headphones,
    Icons.settings_suggest_outlined,
    Icons.bar_chart,
    Icons.settings_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF090B1D),
        border: Border(right: BorderSide(color: Color(0xFF663399))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final active = selected == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    color: active
                        ? const Color(0xFF6220C9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => setState(() => selected = index),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: active
                                ? const Color(0xFFD76AFF)
                                : Colors.transparent,
                          ),
                          boxShadow: active
                              ? const [
                                  BoxShadow(
                                    color: Color(0x665E00FF),
                                    blurRadius: 13,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icons[index],
                              size: 19,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFFC7C9E7),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF260750),
                  Color(0xFF080B20),
                  Color(0xFF44116A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFF9438EF)),
            ),
            child: const Column(
              children: [
                Text(
                  "999",
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE26AFF),
                    shadows: [Shadow(color: Color(0xFFB000FF), blurRadius: 18)],
                  ),
                ),
                Text(
                  "COMMON BEATS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "AI POWERED MUSIC PRODUCTION",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "999 ENTERTAINMENT",
                  style: TextStyle(fontSize: 9, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionWorkflow extends StatelessWidget {
  const _ProductionWorkflow();
  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        "1",
        "Upload Your Beat",
        "Choose your reference audio",
        Icons.upload_file,
      ),
      ("2", "AI Analysis", "Discover the Beat DNA", Icons.psychology),
      ("3", "Set Preferences", "Choose what stays and changes", Icons.tune),
      (
        "4",
        "Generate 20 Beats",
        "Create new musical directions",
        Icons.auto_awesome,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 950
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: steps
              .map(
                (step) => SizedBox(
                  width: width,
                  child: Container(
                    height: 145,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10142B),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xFF9C35F5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color(0xFF7521D8),
                              child: Text(
                                step.$1,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                step.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(step.$4, color: Colors.purpleAccent, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          step.$3,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _BeatVariationLibrary extends StatelessWidget {
  const _BeatVariationLibrary();
  static const styles = [
    "Dark Trap",
    "Melodic Trap",
    "Drill",
    "R&B Fusion",
    "Cinematic",
    "Club Bounce",
    "West Coast",
    "Lo-Fi",
    "Afro Fusion",
    "Experimental",
    "Soul Trap",
    "Ambient",
    "Hard Trap",
    "Jersey Club",
    "Boom Bap",
    "Synthwave",
    "Latin Fusion",
    "Orchestral",
    "Future Bass",
    "Signature Mix",
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10142B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8136DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "20-BEAT VARIATION LIBRARY",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "One Beat. 20 Possibilities. Zero Copies.",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 4
                  : constraints.maxWidth >= 650
                  ? 3
                  : constraints.maxWidth >= 380
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(styles.length, (index) {
                  return SizedBox(
                    width: width,
                    child: Container(
                      height: 118,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171B36),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: const Color(0xFF45386C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                (index + 1).toString().padLeft(2, "0"),
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.graphic_eq,
                                color: Colors.white38,
                                size: 19,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            styles[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Text(
                            "PENDING GENERATION",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
