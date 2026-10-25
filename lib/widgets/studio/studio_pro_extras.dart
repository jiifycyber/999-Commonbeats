import 'package:flutter/material.dart';

class StudioProExtras extends StatelessWidget {
  const StudioProExtras({super.key});
  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFB34DFF);
    final items = <(String, IconData, String)>[
      ("ADVANCED TRACK CONTROLS", Icons.tune, "Track routing / gain / pan"),
      (
        "STUDIO PRO CONTROL CENTER",
        Icons.settings_input_component,
        "Master FX / vocal FX / presets",
      ),
      ("MASTER OUTPUT", Icons.equalizer, "EQ / compressor / limiter"),
      (
        "PREVIEW PLAYER",
        Icons.play_circle_outline,
        "Waveform / playback / transport",
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 850 ? 2 : 1;
        final width = (c.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Container(
                    height: 205,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF11152C),
                      border: Border.all(color: purple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Center(child: Icon(item.$2, color: purple, size: 42)),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            item.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF9EA6C5)),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "ENGINE PENDING",
                          style: TextStyle(
                            color: Color(0xFF9EA6C5),
                            fontSize: 10,
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
