import 'screens/export_pro.dart';
import 'screens/projects_pro.dart';
import 'screens/analytics_pro.dart';
import 'widgets/genesis_ui.dart';
import "services/beat_autosave.dart";
import "services/studio_beat_bridge.dart";
import "services/studio_project_bridge.dart";

import "package:flutter/foundation.dart";
import "package:just_audio/just_audio.dart";

import "screens/studio_pro.dart";
import 'screens/futuristic_studio.dart';

import 'package:flutter/material.dart';

import 'core/genesis_theme.dart';
import 'widgets/ic391_premium_shell.dart';
import 'widgets/ic391_master_panel.dart';

import 'charts/beat_waveform_chart.dart';
import 'services/shared_beats_api.dart';
import 'screens/shared_beats_login.dart';

void main() => runApp(const CommonBeatsApp());

class CommonBeatsApp extends StatelessWidget {
  const CommonBeatsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '999 Common Beats',
    debugShowCheckedModeBanner: false,
    theme: GenesisTheme.dark,
    home: const IC391PremiumTheme(child: CommonBeatsAuthGate()),
  );
}

class CommonBeatsAuthGate extends StatefulWidget {
  const CommonBeatsAuthGate({super.key});
  @override
  State<CommonBeatsAuthGate> createState() => _CommonBeatsAuthGateState();
}

class _CommonBeatsAuthGateState extends State<CommonBeatsAuthGate> {
  bool? signedIn;
  @override
  void initState() {
    super.initState();
    SharedBeatsApi.signedIn.then((v) {
      if (mounted) setState(() => signedIn = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (signedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (signedIn!) {
      return const CommonBeatsTabs();
    }
    return SharedBeatsLogin(onSignedIn: () => setState(() => signedIn = true));
  }
}

class BeatsStudio extends StatefulWidget {
  const BeatsStudio({super.key});
  @override
  State<BeatsStudio> createState() => _BeatsStudioState();
}

class _BeatsStudioState extends State<BeatsStudio> {
  double dna = 95;
  bool reconstruction = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF090914),
    appBar: AppBar(
      title: const Text('999 COMMON BEATS'),
      backgroundColor: const Color(0xFF171126),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI BEAT PRODUCTION STUDIO',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('Beat Reconstruction'),
                  selected: reconstruction,
                  onSelected: (_) => setState(() => reconstruction = true),
                ),
                ChoiceChip(
                  label: const Text('Audio Enhancement'),
                  selected: !reconstruction,
                  onSelected: (_) => setState(() => reconstruction = false),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'ORIGINAL BEAT',
              style: TextStyle(color: Colors.purpleAccent, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const BeatWaveformChart(),
            const SizedBox(height: 25),
            Text(
              reconstruction ? 'RECONSTRUCTED BEAT' : 'ENHANCED BEAT',
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const BeatWaveformChart(reconstructed: true),
            const SizedBox(height: 30),
            Text(
              'BEAT DNA LOCK: ${dna.toInt()}%',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: dna,
              min: 70,
              max: 100,
              divisions: 6,
              activeColor: Colors.purpleAccent,
              onChanged: (value) => setState(() => dna = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Beat - Coming Soon'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Waveforms are demonstration data. Audio generation is not connected yet.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    ),
  );
}

class CommonBeatsTabs extends StatefulWidget {
  const CommonBeatsTabs({super.key});
  @override
  State<CommonBeatsTabs> createState() => _CommonBeatsTabsState();
}

class _CommonBeatsTabsState extends State<CommonBeatsTabs> {
  static final ValueNotifier<int> studioTabRequest = ValueNotifier<int>(0);

  static const labels = [
    "Studio",
    "Projects",
    "Sounds",
    "Mixer",
    "Export",
    "Analytics",
    "Settings",
  ];
  static const icons = [
    Icons.home_rounded,
    Icons.folder_outlined,
    Icons.graphic_eq,
    Icons.tune_rounded,
    Icons.file_upload_outlined,
    Icons.bar_chart_rounded,
    Icons.settings_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: const Color(0xFF070914),
        drawer: mobile
            ? Builder(
                builder: (drawerContext) => Drawer(
                  backgroundColor: GenesisColors.midnight,
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            "999 COMMON BEATS",
                            style: TextStyle(
                              color: GenesisColors.gold,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Divider(color: GenesisColors.gold),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: labels.length,
                            itemBuilder: (context, index) {
                              final active =
                                  DefaultTabController.of(drawerContext)
                                      .index ==
                                  index;
                              final accent = active
                                  ? GenesisColors.gold
                                  : GenesisColors.cyan;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Material(
                                  color: GenesisColors.panelRaised,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Navigator.pop(drawerContext);
                                      DefaultTabController.of(drawerContext)
                                          .animateTo(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 13,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: accent,
                                          width: active ? 1.6 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            icons[index],
                                            color: accent,
                                            size: 21,
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            labels[index].toUpperCase(),
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
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
                      ],
                    ),
                  ),
                ),
              )
            : null,
        body: Column(
          children: [
            if (mobile)
              Builder(
                builder: (headerContext) => IC391PremiumShell(
                  radius: 12,
                  child: Container(
                    height: 76,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: GenesisColors.midnight,
                      border: Border(
                        bottom: BorderSide(color: GenesisColors.gold),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Scaffold.of(headerContext).openDrawer(),
                          icon: const Icon(
                            Icons.menu,
                            color: GenesisColors.gold,
                          ),
                          tooltip: "Open navigation",
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "999",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: GenesisColors.gold,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "COMMON BEATS",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "MATCH. CREATE. ENHANCE.",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 96,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  color: Color(0xFF080713),
                  border: Border(bottom: BorderSide(color: Color(0xFF432061))),
                ),
                child: Row(
                  children: [
                    Text(
                      "999",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -4,
                        color: const Color(0xFFE66AFF),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFB000FF)
                                .withValues(alpha: 0.9),
                            blurRadius: 18,
                          ),
                          Shadow(
                            color: const Color(0xFF7000FF)
                                .withValues(alpha: 0.7),
                            blurRadius: 32,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "COMMON BEATS",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "MATCH. CREATE. ENHANCE.",
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 2,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            dividerHeight: 0,
                            indicator: BoxDecoration(
                              color: const Color(0xFF36105B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFB83AFF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x664D00FF),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            tabs: List.generate(
                              labels.length,
                              (index) => SizedBox(
                                width: 88,
                                height: 68,
                                child: Tab(
                                  icon: Icon(icons[index], size: 23),
                                  text: labels[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF271044),
                      child: Text("999", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jontarius Cooper",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "999 Entertainment",
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  StudioWorkspace(),
                  ProjectsPro(),
                  SoundsStation(),
                  MixerWorkspace(),
                  ExportPro(),
                  AnalyticsPro(),
                  HardwareStudioSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudioWorkspace extends StatefulWidget {
  const StudioWorkspace({super.key});
  @override
  State<StudioWorkspace> createState() => _StudioWorkspaceState();
}

class _StudioWorkspaceState extends State<StudioWorkspace>
    with SingleTickerProviderStateMixin {
  late final TabController studioController;
  @override
  void initState() {
    super.initState();
    studioController = TabController(length: 2, vsync: this);
    _CommonBeatsTabsState.studioTabRequest.addListener(_openStudioPro);
    StudioProjectBridge.openStudioRequest.addListener(_openProjectStudio);
  }

  void _openProjectStudio() {
    if (!mounted) return;
    _openStudioPro();
    DefaultTabController.of(context).animateTo(0);
  }

  void _openStudioPro() {
    if (!mounted) return;
    studioController.animateTo(1);
  }

  @override
  void dispose() {
    _CommonBeatsTabsState.studioTabRequest.removeListener(_openStudioPro);
    StudioProjectBridge.openStudioRequest.removeListener(_openProjectStudio);
    studioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IC391PremiumShell(
          radius: 12,
          child: TabBar(
            controller: studioController,
            indicatorColor: GenesisColors.gold,
            labelColor: GenesisColors.gold,
            unselectedLabelColor: GenesisColors.muted,
            tabs: const [
              Tab(text: "Current Studio"),
              Tab(text: "Studio Pro"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: studioController,
            children: const [FuturisticStudio(), StudioPro()],
          ),
        ),
      ],
    );
  }
}

class MixerWorkspace extends StatefulWidget {
  const MixerWorkspace({super.key});
  @override
  State<MixerWorkspace> createState() => _MixerWorkspaceState();
}

class _MixerWorkspaceState extends State<MixerWorkspace> {
  final channelNames = <String>[
    'Kick In',
    'Kick Out',
    'Snare Top',
    'Snare Bottom',
    'Clap',
    'Hi-Hat',
    'Tom 1',
    'Tom 2',
    'Tom 3',
    'Overhead L',
    'Overhead R',
    'Room L',
    'Room R',
    'Shaker',
    'Percussion',
    'Drum Loop',
    '808 Bass',
    'Bass DI',
    'Bass Amp',
    'Piano L',
    'Piano R',
    'Electric Piano',
    'Organ',
    'Synth Bass',
    'Synth Lead',
    'Synth Pad',
    'Guitar L',
    'Guitar R',
    'Acoustic Guitar',
    'Strings',
    'Brass',
    'Music Loop',
    'Lead Vocal',
    'Lead Double',
    'Hook Lead',
    'Hook Double',
    'Harmony High',
    'Harmony Low',
    'Backing Vocal L',
    'Backing Vocal R',
    'Ad-lib 1',
    'Ad-lib 2',
    'Ad-lib 3',
    'Vocal Chop',
    'Vocal FX Print',
    'Vocal Reference',
    'Vocal Parallel',
    'Extra Vocal',
    'Reverb Short',
    'Reverb Long',
    'Delay 1/4',
    'Delay 1/8',
    'Stereo Delay',
    'Chorus',
    'Doubler',
    'Distortion',
    'Parallel Drums',
    'Parallel Vocals',
    'FX Return 1',
    'FX Return 2',
    'Reference Track',
    'Mix Print',
    'Stem Print',
    'Spare/Utility',
  ];
  static const groupColors = <Color>[
    Color(0xFFB34DFF),
    Color(0xFF4285F4),
    Color(0xFFF5B544),
    Color(0xFF25C9AD),
  ];
  final levels = List<double>.filled(64, 0.65);
  final muted = List<bool>.filled(64, false);
  final solo = List<bool>.filled(64, false);
  final pan = List<double>.filled(64, 0);
  int bank = 0;
  final channelGain = List<double>.filled(64, 0.5);
  final channelEqLow = List<double>.filled(64, 0.5);
  final channelEqMid = List<double>.filled(64, 0.5);
  final channelEqHigh = List<double>.filled(64, 0.5);
  final channelComp = List<double>.filled(64, 0.5);
  final channelGate = List<double>.filled(64, 0);
  final channelReverb = List<double>.filled(64, 0);
  final channelDelay = List<double>.filled(64, 0);
  final channelRouting = List<String>.filled(64, "Main");
  bool showChannelConsole = true;
  Widget channelSlider(String label, List<double> values) => Row(
    children: [
      SizedBox(
        width: 100,
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
      Expanded(
        child: Slider(
          value: values[selected],
          activeColor: const Color(0xFFB34DFF),
          onChanged: (v) => setState(() => values[selected] = v),
        ),
      ),
      SizedBox(
        width: 38,
        child: Text(
          "${(values[selected] * 100).round()}%",
          style: const TextStyle(fontSize: 10),
        ),
      ),
    ],
  );
  int editorSection = 0;
  Widget editorControl(String label, List<double> values) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 115,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: values[selected],
            activeColor: GenesisColors.cyan,
            onChanged: (v) => setState(() => values[selected] = v),
          ),
        ),
        SizedBox(
          width: 45,
          child: Text(
            "${(values[selected] * 100).round()}%",
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    ),
  );
  Widget channelConsole() {
    const sections = ["INPUT", "EQ", "DYNAMICS", "EFFECTS", "ROUTING"];
    final controls = <Widget>[];
    switch (editorSection) {
      case 0:
        controls.addAll([
          editorControl("Input Gain", channelGain),
          editorControl("Channel Level", levels),
          editorControl("Pan", pan),
        ]);
      case 1:
        controls.addAll([
          editorControl("Low EQ", channelEqLow),
          editorControl("Mid EQ", channelEqMid),
          editorControl("High EQ", channelEqHigh),
        ]);
      case 2:
        controls.addAll([
          editorControl("Compressor", channelComp),
          editorControl("Noise Gate", channelGate),
        ]);
      case 3:
        controls.addAll([
          editorControl("Reverb Send", channelReverb),
          editorControl("Delay Send", channelDelay),
        ]);
      case 4:
        controls.addAll([
          Row(
            children: [
              const Text("Output Bus  "),
              DropdownButton<String>(
                value: channelRouting[selected],
                items: ["Main", "Drum Bus", "Music Bus", "Vocal Bus", "FX Bus"]
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => channelRouting[selected] = v);
                },
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            children: [
              FilterChip(
                label: Text(
                  "MUTE",
                  style: TextStyle(
                    color: muted[selected]
                        ? GenesisColors.gold
                        : GenesisColors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: muted[selected],
                selectedColor: GenesisColors.panelRaised,
                backgroundColor: GenesisColors.panelRaised,
                side: BorderSide(
                  color: muted[selected]
                      ? GenesisColors.gold
                      : GenesisColors.cyan,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                showCheckmark: false,
                onSelected: (v) => setState(() => muted[selected] = v),
              ),
              FilterChip(
                label: Text(
                  "SOLO",
                  style: TextStyle(
                    color: solo[selected]
                        ? GenesisColors.gold
                        : GenesisColors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: solo[selected],
                selectedColor: GenesisColors.panelRaised,
                backgroundColor: GenesisColors.panelRaised,
                side: BorderSide(
                  color: solo[selected]
                      ? GenesisColors.gold
                      : GenesisColors.cyan,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                showCheckmark: false,
                onSelected: (v) => setState(() => solo[selected] = v),
              ),
            ],
          ),
        ]);
    }
    return IC391MasterPanel(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "CH ${selected + 1}  |  ${channelNames[selected]}  |  CHANNEL EDITOR V2",
                  style: TextStyle(
                    color: GenesisColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => showChannelConsole = false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                sections.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      sections[i],
                      style: TextStyle(
                        color: editorSection == i
                            ? GenesisColors.gold
                            : GenesisColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: editorSection == i,
                    selectedColor: GenesisColors.panelRaised,
                    backgroundColor: GenesisColors.panelRaised,
                    side: BorderSide(
                      color: editorSection == i
                          ? GenesisColors.gold
                          : GenesisColors.cyan,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => editorSection = i),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...controls,
          const SizedBox(height: 8),
          const Text(
            "Independent channel settings | Audio engine integration pending",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  int selected = 0;
  double master = 0.8;
  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFB34DFF);
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: Column(
        children: [
          if (mobile)
            IC391MasterPanel(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "999 COMMON BEATS | DIGITAL MIXER",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "CH ${selected + 1} - ${channelNames[selected]}",
                    style: const TextStyle(color: GenesisColors.gold),
                  ),
                  Row(
                    children: [
                      const Text("MASTER"),
                      Expanded(
                        child: Slider(
                          value: master,
                          activeColor: GenesisColors.cyan,
                          onChanged: (v) => setState(() => master = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "999 COMMON BEATS | DIGITAL MIXER",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "CH ${selected + 1} - ${channelNames[selected]}",
                    style: const TextStyle(color: purple),
                  ),
                  const SizedBox(width: 16),
                  const Text("MASTER"),
                  SizedBox(
                    width: 130,
                    child: Slider(
                      value: master,
                      activeColor: purple,
                      onChanged: (v) => setState(() => master = v),
                    ),
                  ),
                ],
              ),
            ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            crossAxisCount: 2,
            childAspectRatio: 5,
            mainAxisSpacing: 6,
            crossAxisSpacing: 8,
            children: List.generate(
              4,
              (i) => InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => setState(() => bank = i),
                child: IC391MobileStatPanel(
                  value: "${i * 16 + 1}-${i * 16 + 16}",
                  label: "CH",
                  color: bank == i ? GenesisColors.gold : GenesisColors.cyan,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (mobile) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 0.95,
                          ),
                      itemCount: 16,
                      itemBuilder: (context, i) {
                        final ch = bank * 16 + i;
                        return InkWell(
                          borderRadius: BorderRadius.circular(7),
                          onTap: () => setState(() {
                            selected = ch;
                            showChannelConsole = true;
                          }),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IC391MobileStatPanel(
                                value: "${ch + 1}",
                                label: channelNames[ch],
                                color: selected == ch
                                    ? GenesisColors.gold
                                    : GenesisColors.cyan,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 9,
                                    child: Text(
                                      "G",
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: channelGain[ch].clamp(0.0, 1.0),
                                      minHeight: 3,
                                      color: GenesisColors.cyan,
                                      backgroundColor:
                                          GenesisColors.panelRaised,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      "${(channelGain[ch] * 100).round()}%",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 9,
                                    child: Text(
                                      "L",
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: levels[ch].clamp(0.0, 1.0),
                                      minHeight: 3,
                                      color: GenesisColors.cyan,
                                      backgroundColor:
                                          GenesisColors.panelRaised,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      "${(levels[ch] * 100).round()}%",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 9,
                                    child: Text(
                                      "P",
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: pan[ch].clamp(0.0, 1.0),
                                      minHeight: 3,
                                      color: GenesisColors.cyan,
                                      backgroundColor:
                                          GenesisColors.panelRaised,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      "${(pan[ch] * 100).round()}%",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: GenesisColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Column(
                    children: List.generate(
                      4,
                      (bankRow) => Expanded(
                        child: SizedBox.expand(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(16, (i) {
                              final ch = bankRow * 16 + i;
                              final groupColor = groupColors[bankRow];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Material(
                                    color: selected == ch
                                        ? groupColor.withValues(alpha: 0.30)
                                        : groupColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        selected = ch;
                                        showChannelConsole = true;
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selected == ch
                                                ? Colors.white
                                                : groupColor,
                                            width: selected == ch ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${ch + 1}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: groupColor,
                                              ),
                                            ),
                                            Text(
                                              channelNames[ch],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 8,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: levels[ch],
                                                minHeight: 5,
                                                backgroundColor: Colors.white12,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(groupColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (showChannelConsole)
            SizedBox(
              height: 245,
              child: SingleChildScrollView(child: channelConsole()),
            )
          else
            TextButton.icon(
              onPressed: () => setState(() => showChannelConsole = true),
              icon: const Icon(Icons.tune),
              label: Text("OPEN CHANNEL ${selected + 1} CONTROLS"),
            ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Interactive mixer controls | Audio processing engine pending",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class HardwareStudioSettings extends StatefulWidget {
  const HardwareStudioSettings({super.key});
  @override
  State<HardwareStudioSettings> createState() => _HardwareStudioSettingsState();
}

class _HardwareStudioSettingsState extends State<HardwareStudioSettings> {
  static const purple = GenesisColors.cyan;
  final categories = [
    "General",
    "Audio Engine",
    "MIDI Devices",
    "Hardware Studio",
    "Channels",
    "Effects",
    "File Locations",
    "Appearance",
    "Shortcuts",
    "Backup & Sync",
    "Advanced",
  ];
  final sections = [
    "Device Setup",
    "Input Routing",
    "MIDI Mapping",
    "Mixer Control",
    "Monitor & Output",
    "Latency & Sync",
  ];
  int category = 3;
  int section = 0;
  String input = "System Default";
  String output = "System Default";
  String route = "Channel 1";
  String protocol = "MIDI CC";
  String rate = "48000 Hz";
  double monitor = 0.65;
  double buffer = 256;
  bool midiLearn = false;
  Widget setting(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        SizedBox(width: 135, child: Text(label)),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: options
                .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                .toList(),
            onChanged: (x) {
              if (x != null) setState(() => change(x));
            },
          ),
        ),
      ],
    ),
  );
  Widget device(String name, String description, IconData icon) => Card(
    color: GenesisColors.panelRaised,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 6),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(11),
      side: const BorderSide(color: GenesisColors.cyan, width: 1.4),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: GenesisColors.cyan, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: GenesisColors.midnight,
              border: Border.all(color: GenesisColors.gold),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "NOT DETECTED",
              style: TextStyle(
                color: GenesisColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget hardware() {
    switch (section) {
      case 0:
        return Column(
          children: [
            device(
              "Audio Interface",
              "USB audio inputs and outputs",
              Icons.settings_input_component,
            ),
            setting("Input Device", input, [
              "System Default",
              "Not Selected",
            ], (v) => input = v),
            setting("Output Device", output, [
              "System Default",
              "Not Selected",
            ], (v) => output = v),
            device(
              "MIDI Keyboard",
              "Piano keyboards and pad controllers",
              Icons.piano,
            ),
            device(
              "Physical Mixer",
              "USB MIDI mixer and control surfaces",
              Icons.tune,
            ),
            device("Microphones", "XLR and USB recording inputs", Icons.mic),
            device(
              "Instruments",
              "Guitar, bass and line inputs",
              Icons.music_note,
            ),
            device("Studio Monitors", "Speakers and headphones", Icons.speaker),
          ],
        );
      case 1:
        return Column(
          children: [
            device(
              "Input Routing",
              "Assign audio inputs to 64 channels",
              Icons.alt_route,
            ),
            setting(
              "Target Channel",
              route,
              List.generate(64, (i) => "Channel ${i + 1}"),
              (v) => route = v,
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            device(
              "MIDI Mapping",
              "Map keyboard notes, pads and knobs",
              Icons.keyboard,
            ),
            SwitchListTile(
              title: const Text("MIDI Learn Preview"),
              value: midiLearn,
              onChanged: (v) => setState(() => midiLearn = v),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            device(
              "Mixer Control",
              "Assign physical faders and controls",
              Icons.tune,
            ),
            setting("Protocol", protocol, [
              "MIDI CC",
              "Mackie Control",
              "OSC",
            ], (v) => protocol = v),
          ],
        );
      case 4:
        return Column(
          children: [
            device(
              "Monitor and Output",
              "Configure speakers and headphones",
              Icons.headphones,
            ),
            const Text("Monitor Level"),
            Slider(
              value: monitor,
              activeColor: purple,
              onChanged: (v) => setState(() => monitor = v),
            ),
          ],
        );
      default:
        return Column(
          children: [
            device(
              "Latency and Sync",
              "Audio buffer and sample rate settings",
              Icons.speed,
            ),
            setting("Sample Rate", rate, [
              "44100 Hz",
              "48000 Hz",
              "96000 Hz",
            ], (v) => rate = v),
            Text("Buffer: ${buffer.round()} samples"),
            Slider(
              value: buffer,
              min: 64,
              max: 1024,
              activeColor: purple,
              onChanged: (v) => setState(() => buffer = v),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final narrow = size.maxWidth < 700;
      final sidebar = ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: ListTile(
            dense: true,
            selected: category == i,
            selectedTileColor: GenesisColors.panelRaised,
            tileColor: GenesisColors.panelRaised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
              side: BorderSide(
                color: category == i ? GenesisColors.gold : GenesisColors.cyan,
              ),
            ),
            selectedColor: GenesisColors.gold,
            textColor: GenesisColors.cyan,
            title: Text(
              categories[i],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onTap: () => setState(() => category = i),
          ),
        ),
      );
      final content = ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            category == 3
                ? "HARDWARE STUDIO"
                : categories[category].toUpperCase(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: GenesisColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Professional studio equipment configuration",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 16),
          if (category == 3) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  sections.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(sections[i]),
                      selected: section == i,
                      selectedColor: GenesisColors.panelRaised,
                      backgroundColor: GenesisColors.panelRaised,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: section == i
                            ? GenesisColors.gold
                            : GenesisColors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide(
                        color: section == i
                            ? GenesisColors.gold
                            : GenesisColors.cyan,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      onSelected: (_) => setState(() => section = i),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            hardware(),
            const SizedBox(height: 12),
            device(
              "Connected Devices",
              "Hardware discovery service pending",
              Icons.usb,
            ),
          ] else
            device(
              categories[category],
              "Configuration section planned",
              Icons.settings,
            ),
          const SizedBox(height: 12),
          const Text(
            "Hardware detection and audio engine integration pending",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      );
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: GenesisColors.midnight,
          border: Border.all(color: GenesisColors.cyan, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: narrow
            ? Column(
                children: [
                  SizedBox(height: 160, child: sidebar),
                  Expanded(child: content),
                ],
              )
            : Row(
                children: [
                  SizedBox(width: 205, child: sidebar),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
      );
    },
  );
}

class SoundsStation extends StatefulWidget {
  const SoundsStation({super.key});
  @override
  State<SoundsStation> createState() => _SoundsStationState();
}

class _SoundsStationState extends State<SoundsStation> {
  void loadIntoStudioId(String beatId) {
    StudioBeatBridge.loadBeat(beatId);
    _CommonBeatsTabsState.studioTabRequest.value++;
    DefaultTabController.of(context).animateTo(0);
  }

  final player = AudioPlayer();
  final search = TextEditingController();
  List<String> beats = [];
  String? activeId;
  bool loading = false;
  String? error;
  @override
  void initState() {
    super.initState();
    BeatAutosave.libraryRevision.addListener(refresh);
    refresh();
  }

  Future<void> refresh() async {
    if (!kIsWeb) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await BeatAutosave.listBeatIds();
      results.sort();
      if (mounted) setState(() => beats = results);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String mime(String name) {
    final n = name.toLowerCase();
    if (n.endsWith(".wav")) return "audio/wav";
    if (n.endsWith(".m4a")) return "audio/mp4";
    if (n.endsWith(".flac")) return "audio/flac";
    return "audio/mpeg";
  }

  Future<void> playBeatId(String beatId) async {
    final beat = await BeatAutosave.loadById(beatId);
    if (beat == null) return;
    try {
      if (activeId == beatId && player.playing) {
        await player.pause();
        return;
      }
      if (activeId != beatId) {
        await player.stop();
        await player.setAudioSource(
          _LibraryAudioSource(beat.bytes, mime(beat.name)),
        );
        if (mounted) setState(() => activeId = beatId);
      }
      await player.play();
    } catch (e) {
      if (mounted) setState(() => error = "Playback failed: $e");
    }
  }

  @override
  void dispose() {
    BeatAutosave.libraryRevision.removeListener(refresh);
    player.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = beats
        .asMap()
        .entries
        .where(
          (entry) => "beat ${entry.key + 1}".contains(
            search.text.toLowerCase().trim(),
          ),
        )
        .toList();
    return Container(
      color: GenesisColors.midnight,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "SOUNDS STATION",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: GenesisColors.gold,
            ),
          ),
          const Text(
            "999 Common Beats | Instrumental Library",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Chip(
                label: Text("Total Beats: ${beats.length}"),
                backgroundColor: GenesisColors.panelRaised,
                side: const BorderSide(color: GenesisColors.cyan),
                labelStyle: const TextStyle(
                  color: GenesisColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Chip(
                label: Text("Storage: Browser Library"),
                backgroundColor: GenesisColors.panelRaised,
                side: BorderSide(color: GenesisColors.cyan),
                labelStyle: TextStyle(
                  color: GenesisColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ActionChip(
                avatar: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: GenesisColors.gold,
                ),
                label: const Text(
                  "Refresh Library",
                  style: TextStyle(color: GenesisColors.gold),
                ),
                onPressed: refresh,
                backgroundColor: GenesisColors.panelRaised,
                side: const BorderSide(color: GenesisColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: GenesisColors.cyan),
              hintText: "Search your instrumentals...",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: GenesisColors.cyan),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: GenesisColors.gold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.redAccent)),
          if (!loading && filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(35),
              child: Column(
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 56,
                    color: GenesisColors.cyan,
                  ),
                  SizedBox(height: 12),
                  Text("No instrumentals found"),
                  SizedBox(height: 8),
                  Text(
                    "Upload a beat in Studio, then return here.",
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ...filtered.map((entry) {
            final beatId = entry.value;
            final beatNumber = entry.key + 1;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: GenesisColors.cyan),
              ),
              color: GenesisColors.panelRaised,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.audio_file,
                      color: GenesisColors.cyan,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Beat $beatNumber",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Audio loads on demand",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => loadIntoStudioId(beatId),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Load into Studio Pro"),
                    ),
                    const SizedBox(width: 8),
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing =
                            activeId == beatId &&
                            (snapshot.data?.playing ?? false);
                        return IconButton.filled(
                          tooltip: playing ? "Pause" : "Play",
                          onPressed: () => playBeatId(beatId),
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          const Text(
            "Audio files are stored in this browsers IndexedDB. External SSD backup and Studio load-back are future upgrades.",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ignore: experimental_member_use
class _LibraryAudioSource extends StreamAudioSource {
  final Uint8List data;
  final String contentType;
  _LibraryAudioSource(this.data, this.contentType);
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
      stream: Stream.value(Uint8List.sublistView(data, from, to)),
      contentType: contentType,
    );
  }
}
