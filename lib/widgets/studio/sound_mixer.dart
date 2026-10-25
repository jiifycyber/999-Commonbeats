import "package:flutter/material.dart";

class SoundMixer extends StatefulWidget {
  const SoundMixer({super.key});
  @override
  State<SoundMixer> createState() => _SoundMixerState();
}

class _SoundMixerState extends State<SoundMixer> {
  final Map<String, double> levels = {
    "Drums": 75,
    "Bass": 75,
    "Melody": 75,
    "Effects": 75,
  };
  Widget channel(String name, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(name)),
            Text("${levels[name]!.round()}%"),
          ],
        ),
        Slider(
          value: levels[name]!,
          min: 0,
          max: 100,
          activeColor: Colors.purpleAccent,
          onChanged: (value) {
            setState(() => levels[name] = value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SOUND MIXER",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          channel("Drums", Icons.album),
          channel("Bass", Icons.graphic_eq),
          channel("Melody", Icons.music_note),
          channel("Effects", Icons.tune),
          const Text(
            "Mixer controls are ready for audio engine integration.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
