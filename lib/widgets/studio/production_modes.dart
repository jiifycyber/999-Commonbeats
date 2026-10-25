import "package:flutter/material.dart";

class ProductionModes extends StatefulWidget {
  const ProductionModes({super.key});
  @override
  State<ProductionModes> createState() => _ProductionModesState();
}

class _ProductionModesState extends State<ProductionModes> {
  int selectedMode = 0;
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
            "PRODUCTION MODE",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ChoiceChip(
                label: const Text("Beat Reconstruction"),
                selected: selectedMode == 0,
                onSelected: (_) => setState(() => selectedMode = 0),
              ),
              ChoiceChip(
                label: const Text("Audio Enhancement"),
                selected: selectedMode == 1,
                onSelected: (_) => setState(() => selectedMode = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            selectedMode == 0
                ? "Reconstruction mode selected"
                : "Enhancement mode selected",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
