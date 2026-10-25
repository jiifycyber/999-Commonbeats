import "package:flutter/material.dart";

class BeatDnaPanel extends StatefulWidget {
  const BeatDnaPanel({super.key});
  @override
  State<BeatDnaPanel> createState() => _BeatDnaPanelState();
}

class _BeatDnaPanelState extends State<BeatDnaPanel> {
  double dna = 95;
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
          const Row(
            children: [
              Icon(Icons.lock, color: Colors.purpleAccent),
              SizedBox(width: 10),
              Text(
                "BEAT DNA LOCK",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Target Similarity: \${dna.toInt()}%",
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 20),
          ),
          Slider(
            value: dna,
            min: 70,
            max: 100,
            divisions: 30,
            activeColor: Colors.purpleAccent,
            label: "\${dna.toInt()}%",
            onChanged: (value) => setState(() => dna = value),
          ),
          const Text(
            "Set the desired similarity to your reference beat.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
