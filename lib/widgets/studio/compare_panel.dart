import "package:flutter/material.dart";

import "../../charts/beat_waveform_chart.dart";

class ComparePanel extends StatelessWidget {
  const ComparePanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111629),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.purpleAccent),
              SizedBox(width: 10),
              Text(
                "BEAT COMPARISON",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text("ORIGINAL BEAT", style: TextStyle(color: Colors.purpleAccent)),
          SizedBox(height: 10),
          BeatWaveformChart(),
          SizedBox(height: 20),
          Text("PROCESSED BEAT", style: TextStyle(color: Colors.cyanAccent)),
          SizedBox(height: 10),
          BeatWaveformChart(reconstructed: true),
          SizedBox(height: 16),
          Text(
            "Waveforms are demonstration data until audio analysis is connected.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
