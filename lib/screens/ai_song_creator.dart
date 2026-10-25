import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

import "../services/beat_autosave.dart";

class AISongCreator extends StatefulWidget {
  const AISongCreator({super.key});
  @override
  State<AISongCreator> createState() => _AISongCreatorState();
}

class _AISongCreatorState extends State<AISongCreator> {
  static const bg = Color(0xFF050816);
  static const panel = Color(0xFF101B39);
  static const purple = Color(0xFFB74CFF);
  static const gold = Color(0xFFFFD24C);
  final prompt = TextEditingController();
  final lyrics = TextEditingController();
  final title = TextEditingController();
  String genre = "Hip-Hop";
  String vocal = "AI Rapper";
  bool instrumental = false;
  SavedBeat? selectedAudio;
  final AudioPlayer previewPlayer = AudioPlayer();
  bool previewPlaying = false;
  String _audioMime(String name) {
    final n = name.toLowerCase();
    if (n.endsWith(".wav")) return "audio/wav";
    if (n.endsWith(".m4a")) return "audio/mp4";
    if (n.endsWith(".flac")) return "audio/flac";
    return "audio/mpeg";
  }

  Future<void> _togglePreview() async {
    final beat = selectedAudio;
    if (beat == null) return;
    try {
      if (previewPlayer.playing) {
        await previewPlayer.pause();
        if (mounted) setState(() => previewPlaying = false);
        return;
      }
      if (previewPlayer.audioSource == null) {
        await previewPlayer.setAudioSource(
          _SongMemoryAudioSource(beat.bytes, _audioMime(beat.name)),
        );
      }
      if (previewPlayer.processingState == ProcessingState.completed) {
        await previewPlayer.seek(Duration.zero);
      }
      previewPlayer.play();
      if (mounted) setState(() => previewPlaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Audio preview failed: $e")));
      }
    }
  }

  Future<void> _chooseAudio() async {
    try {
      final beats = await BeatAutosave.listAll();
      beats.sort((a, b) => a.id.compareTo(b.id));
      if (!mounted) return;
      final chosen = await showModalBottomSheet<SavedBeat>(
        context: context,
        backgroundColor: panel,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "SOUNDS STATION - BEAT LIBRARY",
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (beats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No saved beats yet. Upload a beat in Sounds Station first.",
                    ),
                  ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: beats.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.music_note, color: purple),
                      title: Text("Beat ${index + 1}"),
                      subtitle: Text(
                        "${(beats[index].bytes.length / 1048576).toStringAsFixed(2)} MB",
                      ),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => Navigator.pop(sheetContext, beats[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (chosen != null && mounted) {
        await previewPlayer.stop();
        if (!mounted) return;
        setState(() {
          selectedAudio = chosen;
          previewPlaying = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not load beats: $error")));
      }
    }
  }

  @override
  void dispose() {
    previewPlayer.dispose();
    prompt.dispose();
    lyrics.dispose();
    title.dispose();
    super.dispose();
  }

  Widget section(String name, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF10254B), Color(0xFF170F38)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: purple.withValues(alpha: .75)),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: purple.withValues(alpha: .13), blurRadius: 22),
      ],
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: name == "LYRICS" || name == "STYLES",
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        leading: const Icon(Icons.auto_awesome, color: Color(0xFF25EDFF)),
        title: Text(
          name,
          style: const TextStyle(
            color: gold,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        iconColor: purple,
        collapsedIconColor: gold,
        children: [child],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: bg,
      title: const Text(
        "AI SONG CREATOR",
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4),
      ),
      foregroundColor: gold,
    ),
    body: Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: bg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF080F25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF314B7B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: purple, width: 2),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF152B55), Color(0xFF261344)],
              ),
              border: Border.all(color: purple, width: 1.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _chooseAudio,
                    icon: const Icon(Icons.library_music),
                    label: const Text("SOUNDS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: const BorderSide(color: gold),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Voice recording coming next"),
                      ),
                    ),
                    icon: const Icon(Icons.mic),
                    label: const Text("VOICE"),
                  ),
                ),
              ],
            ),
          ),
          if (selectedAudio != null)
            Card(
              color: const Color(0xFF10254B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFF25EDFF)),
              ),
              child: ListTile(
                leading: const Icon(Icons.library_music, color: gold),
                title: FutureBuilder<List<SavedBeat>>(
                  future: BeatAutosave.listAll(),
                  builder: (context, snapshot) {
                    final ordered = [...?snapshot.data]
                      ..sort((a, b) => a.id.compareTo(b.id));
                    final index = ordered.indexWhere(
                      (b) => b.id == selectedAudio!.id,
                    );
                    return Text(
                      index >= 0
                          ? "Selected: Beat ${index + 1}"
                          : "Selected audio",
                    );
                  },
                ),
                subtitle: const Text("From Sounds Station"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: "Play or pause beat",
                      icon: Icon(
                        previewPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: const Color(0xFF25EDFF),
                        size: 34,
                      ),
                      onPressed: _togglePreview,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        await previewPlayer.stop();
                        if (mounted) {
                          setState(() {
                            selectedAudio = null;
                            previewPlaying = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          section(
            "LYRICS",
            Column(
              children: [
                TextField(
                  controller: lyrics,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: "Write lyrics or describe your song...",
                  ),
                ),
                SwitchListTile(
                  title: const Text("Instrumental"),
                  value: instrumental,
                  activeThumbColor: purple,
                  onChanged: (v) => setState(() => instrumental = v),
                ),
              ],
            ),
          ),
          section(
            "STYLES",
            Column(
              children: [
                TextField(
                  controller: prompt,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Describe what your song should sound like...",
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: genre,
                  items:
                      [
                            "Hip-Hop",
                            "Trap",
                            "R&B",
                            "Pop",
                            "Soul",
                            "Rock",
                            "Afrobeats",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => genre = v ?? genre),
                ),
              ],
            ),
          ),
          section(
            "MORE OPTIONS",
            ExpansionTile(
              title: const Text("Advanced Song Settings"),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: vocal,
                  items:
                      [
                            "AI Rapper",
                            "AI Singer",
                            "Melodic Rap",
                            "Female Vocal",
                            "Male Vocal",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => vocal = v ?? vocal),
                ),
              ],
            ),
          ),
          section(
            "SONG TITLE",
            TextField(
              controller: title,
              decoration: const InputDecoration(hintText: "Name your song"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("AI generation backend coming next"),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                "CREATE SONG",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ignore: experimental_member_use
class _SongMemoryAudioSource extends StreamAudioSource {
  final List<int> data;
  final String contentType;
  _SongMemoryAudioSource(this.data, this.contentType);

  @override
  // ignore: experimental_member_use
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = (start ?? 0).clamp(0, data.length);
    final to = (end ?? data.length).clamp(from, data.length);
    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: data.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(data.sublist(from, to)),
      contentType: contentType,
    );
  }
}
