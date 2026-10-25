import 'dart:math' as math;

import 'ai_song_creator.dart';

import '../services/beat_autosave.dart';
import '../services/studio_beat_bridge.dart';

import 'package:just_audio/just_audio.dart';

import 'package:flutter/material.dart';

const _bg = Color(0xFF050A19);
const _purple = Color(0xFFB74CFF);
const _muted = Color(0xFFABB2D0);

class StudioPro extends StatefulWidget {
  const StudioPro({super.key});
  @override
  State<StudioPro> createState() => _StudioProState();
}

class _StudioProState extends State<StudioPro> {
  final AudioPlayer instrumentalPlayer = AudioPlayer();
  SavedBeat? loadedInstrumental;
  String get loadedBeatLabel {
    final id = loadedInstrumental?.id;
    if (id == null) return "No instrumental loaded";
    final index = libraryBeats.indexWhere((beat) => beat.id == id);
    return index < 0 ? "Beat" : "Beat ${index + 1}";
  }

  List<SavedBeat> libraryBeats = [];
  bool libraryLoading = false;
  String beatSearch = "";

  String? audioError;
  bool audioLoading = false;
  @override
  void initState() {
    super.initState();
    StudioBeatBridge.selectedBeatId.addListener(_receiveBeat);
    _receiveBeat();
    _refreshBeatLibrary();
  }

  Future<void> _receiveBeat() async {
    final id = StudioBeatBridge.selectedBeatId.value;
    if (id == null) return;
    setState(() {
      audioLoading = true;
      audioError = null;
    });
    try {
      final beat = await BeatAutosave.loadById(id);
      if (beat == null) throw StateError("Instrumental not found");
      await instrumentalPlayer.stop();
      await instrumentalPlayer.setAudioSource(
        _StudioMemoryAudioSource(beat.bytes, _audioMime(beat.name)),
      );
      if (mounted) setState(() => loadedInstrumental = beat);
    } catch (e) {
      if (mounted) setState(() => audioError = e.toString());
    } finally {
      if (mounted) setState(() => audioLoading = false);
    }
  }

  Future<void> _refreshBeatLibrary() async {
    setState(() => libraryLoading = true);
    try {
      final items = await BeatAutosave.listAll();
      items.sort((a, b) => a.id.compareTo(b.id));
      if (mounted) setState(() => libraryBeats = items);
    } catch (e) {
      if (mounted) setState(() => audioError = e.toString());
    } finally {
      if (mounted) setState(() => libraryLoading = false);
    }
  }

  Future<void> _loadLibraryBeat(SavedBeat beat) async {
    StudioBeatBridge.loadBeat(beat.id);
  }

  String _audioMime(String name) {
    final n = name.toLowerCase();
    if (n.endsWith(".wav")) return "audio/wav";
    if (n.endsWith(".m4a")) return "audio/mp4";
    if (n.endsWith(".flac")) return "audio/flac";
    return "audio/mpeg";
  }

  Future<void> _toggleInstrumental() async {
    if (loadedInstrumental == null) return;
    if (instrumentalPlayer.playing) {
      await instrumentalPlayer.pause();
    } else {
      await instrumentalPlayer.play();
    }
  }

  static const colors = [
    Color(0xFFC943FF),
    Color(0xFF448FFF),
    Color(0xFFFF42B1),
    Color(0xFFFFA52C),
    Color(0xFF13DF91),
    Color(0xFF00D6E8),
    Color(0xFFFF5472),
    Color(0xFFFFD24C),
  ];
  int? selectedBeat;
  String filter = 'All';
  String track = 'Lead Vocals';
  String trackTab = 'Track';
  String fxTab = 'Master FX';
  String masterTab = 'EQ';
  String exportFormat = 'Full Song';
  String sampleRate = '44.1 kHz';
  String bitDepth = '24 bit';
  String quality = 'High (320 kbps)';
  String preset = 'Studio Hall';
  bool autoTune = true, normalize = true, includeFx = true, metadata = true;
  final fileName = TextEditingController(text: 'My Song');
  final saveLocation = TextEditingController(text: '/999 Beats/Projects');
  final levels = List<double>.filled(8, .65);
  final muted = List<bool>.filled(8, false);
  final solo = List<bool>.filled(8, false);
  final knobs = List<double>.filled(5, .5);
  double pitch = .5, formant = .5, deesser = .5, gate = .3, reverb = .2;
  @override
  void dispose() {
    StudioBeatBridge.selectedBeatId.removeListener(_receiveBeat);
    instrumentalPlayer.dispose();
    fileName.dispose();
    saveLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    body: LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 1050;
        final width = wide ? bounds.maxWidth - 24 : bounds.maxWidth - 20;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  for (final panel in <Widget>[
                    _songCreator(),
                    _library(),
                    _editor(),
                    _mixer(),
                    _trackControls(),
                    _controlCenter(),
                    _master(),
                    _player(),
                    _export(),
                  ]) ...[panel, const SizedBox(height: 10)],
                  const SizedBox(height: 10),
                  const Text(
                    'STUDIO PRO UI PREVIEW • Audio generation, processing, playback and export engines are not connected.',
                    style: TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _box(String title, Widget child, {Widget? trailing}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(1.5),
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF25EDFF), Color(0xFFB74CFF), Color(0xFFFF4DC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),

      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Color(0x332F74FF), blurRadius: 24, spreadRadius: 1),
        BoxShadow(color: Color(0x22B74CFF), blurRadius: 18),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10254B), Color(0xFF170F38)],
        ),
        borderRadius: BorderRadius.circular(18.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.graphic_eq, color: Color(0xFF25EDFF), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFD24C),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(color: Color(0xFF38548A), height: 24),
          child,
        ],
      ),
    ),
  );
  Widget _pill(String text, {bool active = false, VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6324B8) : const Color(0xFF101B39),
            border: Border.all(
              color: active ? const Color(0xFF25EDFF) : const Color(0xFF465C91),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? const Color(0xFFFFD24C) : Colors.white,
            ),
          ),
        ),
      );
  Widget _chips(
    List<String> values,
    String current,
    ValueChanged<String> changed,
  ) => Wrap(
    spacing: 5,
    runSpacing: 6,
    children: values
        .map(
          (s) => _pill(
            s,
            active: s == current,
            onTap: () => setState(() => changed(s)),
          ),
        )
        .toList(),
  );
  Widget _wave(int seed, Color color, {double height = 28}) => CustomPaint(
    painter: _WavePainter(seed, color),
    child: SizedBox(height: height, width: double.infinity),
  );
  Widget _label(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
  );

  Widget _songCreator() => _box(
    "AI SONG CREATOR",
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create original songs, write lyrics, choose vocal styles and produce music with AI.",
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AISongCreator())),
            icon: const Icon(Icons.auto_awesome),
            label: const Text("OPEN AI SONG CREATOR"),
          ),
        ),
      ],
    ),
  );
  Widget _library() => _box(
    "BEAT LIBRARY",
    Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => beatSearch = value),
          decoration: const InputDecoration(
            isDense: true,
            hintText: "Search Beat 1, Beat 2, Beat 3...",
            prefixIcon: Icon(Icons.search, size: 18),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              "${libraryBeats.length} saved beats",
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
            const Spacer(),
            IconButton(
              tooltip: "Refresh Beats",
              onPressed: _refreshBeatLibrary,
              icon: const Icon(Icons.refresh, color: _purple),
            ),
          ],
        ),
        if (libraryLoading) const LinearProgressIndicator(),
        if (!libraryLoading && libraryBeats.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              "No beats saved yet. Upload an instrumental in Studio.",
              style: TextStyle(color: _muted),
            ),
          ),
        ...libraryBeats
            .asMap()
            .entries
            .where(
              (entry) => "beat ${entry.key + 1}".contains(
                beatSearch.toLowerCase().trim(),
              ),
            )
            .map((entry) {
              final beat = entry.value;
              final number = entry.key + 1;
              final active = loadedInstrumental?.id == beat.id;
              final color = colors[entry.key % colors.length];
              return InkWell(
                onTap: () => _loadLibraryBeat(beat),
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF28174D)
                        : const Color(0xFF0A1024),
                    border: Border.all(
                      color: active ? _purple : const Color(0xFF283557),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active ? Icons.check_circle : Icons.play_circle_fill,
                        color: color,
                        size: 24,
                      ),
                      const SizedBox(width: 9),
                      SizedBox(
                        width: 92,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Beat $number",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              "${(beat.bytes.length / 1048576).toStringAsFixed(2)} MB",
                              style: const TextStyle(
                                fontSize: 9,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _wave(number, color, height: 26)),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: "Load Beat $number",
                        onPressed: () => _loadLibraryBeat(beat),
                        icon: const Icon(
                          Icons.library_music,
                          color: _purple,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ],
    ),
  );
  Widget _editor() => _box(
    'SONG PREVIEW & EDITOR',
    Column(
      children: [
        Row(
          children: [
            const Text('BPM', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 7),
            _pill('140'),
            const SizedBox(width: 6),
            _pill('C# Minor'),
            const SizedBox(width: 6),
            _pill('4/4'),
            const Spacer(),
            _pill('0:00 / 3:56'),
            const SizedBox(width: 7),
            const Icon(Icons.skip_previous, size: 23),
            StreamBuilder<PlayerState>(
              stream: instrumentalPlayer.playerStateStream,
              builder: (context, snapshot) => IconButton(
                tooltip: loadedBeatLabel,
                onPressed: loadedInstrumental == null
                    ? null
                    : _toggleInstrumental,
                icon: Icon(
                  snapshot.data?.playing == true
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: _purple,
                  size: 30,
                ),
              ),
            ),
            const Icon(Icons.skip_next, size: 23),
            const Icon(
              Icons.fiber_manual_record,
              color: Colors.redAccent,
              size: 19,
            ),
          ],
        ),
        if (loadedInstrumental != null)
          Text(
            "Loaded: $loadedBeatLabel",
            style: const TextStyle(color: _purple, fontSize: 11),
          ),
        if (audioLoading) const LinearProgressIndicator(),
        if (audioError != null)
          Text(
            audioError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        const SizedBox(height: 13),
        Row(
          children: [
            const SizedBox(width: 114),
            ...List.generate(
              6,
              (i) => Expanded(
                child: Text(
                  '${i * 40}s',
                  style: const TextStyle(fontSize: 9, color: _muted),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(5, (i) {
          final names = [
            'Instrumental',
            'Lead Vocals',
            'Hook',
            'Ad-libs',
            'FX',
          ];
          return Container(
            height: 47,
            margin: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 114,
                  child: Row(
                    children: [
                      Icon(
                        [
                          Icons.music_note,
                          Icons.mic,
                          Icons.mic,
                          Icons.record_voice_over,
                          Icons.auto_awesome,
                        ][i],
                        color: colors[i],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          names[i],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const Text(
                        'M S',
                        style: TextStyle(fontSize: 9, color: _muted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors[i].withValues(alpha: .12),
                      border: Border.all(color: colors[i]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i == 0
                              ? (loadedInstrumental == null
                                    ? 'Audio pending'
                                    : loadedBeatLabel)
                              : names[i],
                          style: const TextStyle(fontSize: 9),
                        ),
                        Expanded(child: _wave(i + 20, colors[i], height: 24)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: _pill(
            '+ Add Track',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Track editing will be enabled with the audio engine.',
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _mixer() => _box(
    'BEAT & VOCAL MIXER',
    Column(
      children: [
        const Text(
          'Channel controls • engine pending',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 225,
          child: Row(
            children: List.generate(
              8,
              (i) => Expanded(
                child: Column(
                  children: [
                    FittedBox(
                      child: Text(
                        [
                          'Drums',
                          'Bass',
                          'Melody',
                          'Vocals',
                          'Hook',
                          'Ad-libs',
                          'FX',
                          'Master',
                        ][i],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          value: levels[i],
                          activeColor: colors[i],
                          onChanged: (v) => setState(() => levels[i] = v),
                        ),
                      ),
                    ),
                    Text(
                      '${((levels[i] - 1) * 10).toStringAsFixed(1)} dB',
                      style: const TextStyle(fontSize: 9),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => muted[i] = !muted[i]),
                            child: Text(
                              ' M ',
                              style: TextStyle(
                                fontSize: 11,
                                color: muted[i] ? Colors.red : _muted,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => solo[i] = !solo[i]),
                            child: Text(
                              ' S ',
                              style: TextStyle(
                                fontSize: 11,
                                color: solo[i] ? Colors.green : _muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _trackControls() => _box(
    'ADVANCED TRACK CONTROLS',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chips(
          ['Track', 'Routing', 'EQ', 'Compression', 'Pan & Gain', 'Automation'],
          trackTab,
          (s) => trackTab = s,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: track,
          isDense: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.mic, size: 18),
          ),
          items: ['Lead Vocals', 'Instrumental', 'Hook', 'Ad-libs', 'FX']
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(fontSize: 11)),
                ),
              )
              .toList(),
          onChanged: (s) => setState(() => track = s!),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Auto Tune', style: TextStyle(fontSize: 11)),
            const Spacer(),
            Switch(
              value: autoTune,
              onChanged: (v) => setState(() => autoTune = v),
            ),
          ],
        ),
        _compactSlider('Pitch', pitch, (v) => setState(() => pitch = v)),
        _compactSlider('Formant', formant, (v) => setState(() => formant = v)),
        _compactSlider('De-esser', deesser, (v) => setState(() => deesser = v)),
        _compactSlider('Gate', gate, (v) => setState(() => gate = v)),
        _compactSlider('Reverb', reverb, (v) => setState(() => reverb = v)),
      ],
    ),
  );
  Widget _compactSlider(
    String label,
    double value,
    ValueChanged<double> update,
  ) => SizedBox(
    height: 40,
    child: Row(
      children: [
        SizedBox(
          width: 66,
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _purple,
              inactiveTrackColor: const Color(0xFF263D69),
              thumbColor: const Color(0xFF25EDFF),
              overlayColor: const Color(0x3325EDFF),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(value: value, onChanged: update),
          ),
        ),
        SizedBox(
          width: 27,
          child: Text(
            '${(value * 100).round()}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFFFD24C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _export() => _box(
    'EXPORT & SAVE',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your future export format and settings',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 10),
        _chips(
          ['Full Song', 'Stems', 'MP3', 'WAV', 'Track Out', 'MIDI'],
          exportFormat,
          (s) => exportFormat = s,
        ),
        const SizedBox(height: 12),
        _label('File Name'),
        TextField(
          controller: fileName,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        _label('Save Location'),
        TextField(
          controller: saveLocation,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.folder_outlined),
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Export Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _dropdown('Sample Rate', sampleRate, [
                '44.1 kHz',
                '48 kHz',
                '96 kHz',
              ], (v) => sampleRate = v),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _dropdown('Bit Depth', bitDepth, [
                '16 bit',
                '24 bit',
                '32 bit',
              ], (v) => bitDepth = v),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _dropdown('Quality', quality, [
          'High (320 kbps)',
          'Standard',
          'Lossless',
        ], (v) => quality = v),
        const SizedBox(height: 10),
        _toggle(
          'Normalize Audio',
          normalize,
          (v) => setState(() => normalize = v),
        ),
        _toggle(
          'Include Master FX',
          includeFx,
          (v) => setState(() => includeFx = v),
        ),
        _toggle('Add Metadata', metadata, (v) => setState(() => metadata = v)),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.download),
            label: const Text('Export Song • Engine Pending'),
          ),
        ),
      ],
    ),
  );
  Widget _dropdown(
    String label,
    String current,
    List<String> values,
    ValueChanged<String> update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      DropdownButtonFormField<String>(
        initialValue: current,
        isDense: true,
        isExpanded: true,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFF101B39),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF465C91)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFB74CFF), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        ),
        items: values
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 10)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => update(v!)),
      ),
    ],
  );
  Widget _toggle(String label, bool value, ValueChanged<bool> change) =>
      SizedBox(
        height: 35,
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
            Switch(
              value: value,
              onChanged: change,
              activeThumbColor: const Color(0xFF25EDFF),
              activeTrackColor: _purple,
            ),
          ],
        ),
      );

  Widget _controlCenter() => _box(
    'STUDIO PRO CONTROL CENTER',
    Column(
      children: [
        _chips(
          ['Master FX', 'Vocal FX', 'Beat FX', 'Presets', 'AI Tools'],
          fxTab,
          (s) => fxTab = s,
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            6,
            (i) => Expanded(
              child: Column(
                children: [
                  Icon(
                    [
                      Icons.graphic_eq,
                      Icons.timelapse,
                      Icons.waves,
                      Icons.blur_circular,
                      Icons.tune,
                      Icons.equalizer,
                    ][i],
                    color: colors[i],
                    size: 22,
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    child: Text(
                      [
                        'Reverb',
                        'Delay',
                        'Chorus',
                        'Flanger',
                        'Distortion',
                        'Limiter',
                      ][i],
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Column(
                children: [
                  Text(
                    ['Mix', 'Size', 'Damping', 'Feedback'][i],
                    style: const TextStyle(fontSize: 10),
                  ),
                  Slider(
                    value: knobs[i],
                    activeColor: _purple,
                    onChanged: (v) => setState(() => knobs[i] = v),
                  ),
                  Text(
                    '${(knobs[i] * 100).round()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _dropdown('Preset', preset, [
          'Studio Hall',
          'Vocal Clarity',
          'Deep Bass',
          'Club Master',
        ], (v) => preset = v),
      ],
    ),
  );

  Widget _master() => _box(
    'MASTER OUTPUT',
    Column(
      children: [
        _chips(
          ['EQ', 'Compressor', 'Limiter', 'Stereo', 'Metering'],
          masterTab,
          (s) => masterTab = s,
        ),
        const SizedBox(height: 10),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF090F22),
            border: Border.all(color: const Color(0xFF26365A)),
          ),
          child: CustomPaint(painter: _EqPainter()),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (i) => Expanded(
              child: Column(
                children: [
                  Text(
                    ['Low', 'Low Mid', 'Mid', 'High Mid', 'High'][i],
                    style: const TextStyle(fontSize: 9),
                  ),
                  Slider(
                    value: knobs[i],
                    activeColor: _purple,
                    onChanged: (v) => setState(() => knobs[i] = v),
                  ),
                  const Text('0 dB', style: TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'COMPRESSOR / LIMITER • PREVIEW',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _player() => _box(
    'PREVIEW PLAYER',
    Column(
      children: [
        const SizedBox(height: 10),
        _wave(48, _purple, height: 60),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: LinearProgressIndicator(value: 0, minHeight: 5)),
            SizedBox(width: 8),
            Text('0:00 / 0:00', style: TextStyle(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.skip_previous, size: 28),
            SizedBox(width: 14),
            IconButton(
              onPressed: loadedInstrumental == null
                  ? null
                  : _toggleInstrumental,
              icon: const Icon(
                Icons.play_circle_fill,
                color: _purple,
                size: 46,
              ),
            ),
            SizedBox(width: 14),
            Icon(Icons.skip_next, size: 28),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.volume_up, size: 18),
            Expanded(child: Slider(value: .6, onChanged: null)),
          ],
        ),
        const Text(
          'NO AUDIO LOADED',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _WavePainter extends CustomPainter {
  final int seed;
  final Color color;
  _WavePainter(this.seed, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (double x = 1; x < size.width; x += 3) {
      final envelope = .25 + .75 * math.sin(x / size.width * math.pi).abs();
      final h = (2 + random.nextDouble() * size.height * .45 * envelope);
      canvas.drawLine(
        Offset(x, size.height / 2 - h),
        Offset(x, size.height / 2 + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      seed != oldDelegate.seed || color != oldDelegate.color;
}

class _EqPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF243456)
      ..strokeWidth = .6;
    for (var i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()..moveTo(0, size.height * .62);
    for (double x = 0; x <= size.width; x += 3) {
      final y =
          size.height * (.5 + .15 * math.sin(x / size.width * math.pi * 5));
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB34DFF)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ignore: experimental_member_use
class _StudioMemoryAudioSource extends StreamAudioSource {
  final List<int> data;
  final String contentType;
  _StudioMemoryAudioSource(this.data, this.contentType);
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
