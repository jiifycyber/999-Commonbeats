import "package:file_picker/file_picker.dart";

import "../../services/beat_autosave.dart";

import "package:flutter/foundation.dart";

import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

class UploadPanel extends StatefulWidget {
  const UploadPanel({super.key});
  @override
  State<UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<UploadPanel> {
  final AudioPlayer player = AudioPlayer();
  String? selectedFile;
  String? errorMessage;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    restoreSavedBeat();
  }

  Future<void> restoreSavedBeat() async {
    if (!kIsWeb) return;
    try {
      final beat = await BeatAutosave.restoreLatest();
      if (beat == null || !mounted) return;
      await player.setAudioSource(
        _MemoryAudioSource(beat.bytes, audioMime(beat.name)),
      );
      if (mounted) setState(() => selectedFile = beat.name);
    } catch (error) {
      if (mounted) setState(() => errorMessage = "Restore failed: $error");
    }
  }

  String audioMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith(".wav")) return "audio/wav";
    if (lower.endsWith(".m4a")) return "audio/mp4";
    if (lower.endsWith(".flac")) return "audio/flac";
    return "audio/mpeg";
  }

  Future<void> chooseFile() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["mp3", "wav", "m4a", "flac"],
      );
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      await player.stop();
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final mime = audioMime(file.name);
        await player.setAudioSource(_MemoryAudioSource(bytes, mime));
        await BeatAutosave.save(file.name, bytes);
      } else {
        final path = file.path;
        if (path == null || path.isEmpty) {
          throw StateError("Selected file has no local path");
        }
        await player.setFilePath(path);
      }
      if (!mounted) return;
      setState(() => selectedFile = file.name);
    } catch (error) {
      if (mounted) {
        setState(() => errorMessage = error.toString());
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Widget panel(Widget child) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF0B1021),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF383253)),
    ),
    child: child,
  );
  @override
  Widget build(BuildContext context) {
    final upload = panel(
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 8),
            const Text("Drag and drop your audio file here"),
            const Text(
              "Or click to browse",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loading ? null : chooseFile,
              icon: const Icon(Icons.audio_file),
              label: Text(loading ? "Loading..." : "Choose File"),
            ),
            const SizedBox(height: 8),
            const Text(
              "MP3 / WAV / M4A / FLAC",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
    final preview = panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedFile ?? "No reference beat selected",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final duration = player.duration ?? Duration.zero;
              final position = snapshot.data ?? Duration.zero;
              final total = duration.inMilliseconds.toDouble();
              return Column(
                children: [
                  Slider(
                    value: total > 0
                        ? position.inMilliseconds.toDouble().clamp(0.0, total)
                        : 0,
                    max: total > 0 ? total : 1,
                    activeColor: Colors.purpleAccent,
                    onChanged: selectedFile == null || total <= 0
                        ? null
                        : (value) => player.seek(
                            Duration(milliseconds: value.toInt()),
                          ),
                  ),
                  Text(
                    "${position.inSeconds}s / ${duration.inSeconds}s",
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              );
            },
          ),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return Center(
                child: IconButton.filled(
                  onPressed: selectedFile == null
                      ? null
                      : () async {
                          if (playing) {
                            await player.pause();
                          } else {
                            if (player.processingState ==
                                ProcessingState.completed) {
                              await player.seek(Duration.zero);
                            }
                            await player.play();
                          }
                        },
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
              );
            },
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111629),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purpleAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. Upload Your Reference Beat",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: upload,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: preview,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: SizedBox(height: 180, child: upload)),
                  const SizedBox(width: 12),
                  Expanded(child: SizedBox(height: 220, child: preview)),
                ],
              );
            },
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: experimental_member_use
class _MemoryAudioSource extends StreamAudioSource {
  final List<int> data;
  final String mime;
  _MemoryAudioSource(this.data, this.mime);
  @override
  // ignore: experimental_member_use
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final begin = (start ?? 0).clamp(0, data.length);
    final finish = (end ?? data.length).clamp(begin, data.length);
    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: data.length,
      contentLength: finish - begin,
      offset: begin,
      stream: Stream.value(data.sublist(begin, finish)),
      contentType: mime,
    );
  }
}
