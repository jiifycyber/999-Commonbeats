import 'package:flutter/material.dart';

class ExportPro extends StatefulWidget {
  const ExportPro({super.key});
  @override
  State<ExportPro> createState() => _ExportProState();
}

class _ExportProState extends State<ExportPro> {
  String selectedMethod = "Full Song";
  String selectedFormat = "WAV";
  String selectedDestination = "Download to Device";
  final Map<String, bool> options = {};
  final Map<String, String> quality = {};

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050D1B),
    body: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF25EDFF), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'EXPORT PRO',
            style: TextStyle(
              color: Color(0xFFE2B84F),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "1. EXPORT METHOD",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      "Full Song",
                      "Instrumental",
                      "Acapella",
                      "Individual Stems",
                      "Multitrack",
                      "Loop / Region",
                      "Mastered",
                      "Unmastered",
                      "Project Package",
                      "MIDI Only",
                      "Project Info JSON",
                      "Batch Export",
                    ]
                    .map(
                      (x) => GestureDetector(
                        onTap: () => setState(() => selectedMethod = x),
                        child: Container(
                          width: 165,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selectedMethod == x
                                ? const Color(0xFF263017)
                                : const Color(0xFF0A1930),
                            border: Border.all(
                              color: selectedMethod == x
                                  ? const Color(0xFFE2B84F)
                                  : const Color(0xFF25EDFF),
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            x,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            "2. EXPORT FORMAT",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      "WAV",
                      "MP3",
                      "FLAC",
                      "AAC / M4A",
                      "AIFF",
                      "OGG Vorbis",
                      "Opus",
                      "MIDI (.mid)",
                      "ZIP (.zip)",
                      "JSON (.json)",
                      "Broadcast WAV",
                      "RF64",
                    ]
                    .map(
                      (x) => GestureDetector(
                        onTap: () => setState(() => selectedFormat = x),
                        child: Container(
                          width: 105,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selectedFormat == x
                                ? const Color(0xFF263017)
                                : const Color(0xFF0A1930),
                            border: Border.all(
                              color: selectedFormat == x
                                  ? const Color(0xFFE2B84F)
                                  : const Color(0xFF25EDFF),
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              x,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            "3. QUALITY SETTINGS",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...{
            "Sample Rate": ["44100 Hz", "48000 Hz", "96000 Hz", "192000 Hz"],
            "Bit Depth": ["16 bit", "24 bit", "32 bit float"],
            "Bitrate": ["128 kbps", "192 kbps", "256 kbps", "320 kbps"],
            "Channel Format": ["Mono", "Stereo"],
          }.entries.map(
            (entry) => Card(
              color: const Color(0xFF0A1930),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF25EDFF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Color(0xFF25EDFF)),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF0A1930),
                        value: quality[entry.key] ?? entry.value.first,
                        items: entry.value
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => quality[entry.key] = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "4. EXPORT OPTIONS",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          ...[
            "Normalize Audio",
            "Master Compression",
            "Include Metadata",
            "Include Individual Stems",
            "Create Loop Version",
            "Verify Exported Files",
          ].map(
            (x) => Card(
              color: const Color(0xFF0A1930),
              child: ListTile(
                title: Text(x),
                trailing: Switch(
                  value:
                      options[x] ??
                      (x == "Normalize Audio" ||
                          x == "Include Metadata" ||
                          x == "Verify Exported Files"),
                  activeThumbColor: const Color(0xFFE2B84F),
                  activeTrackColor: const Color(0xFF25EDFF),
                  onChanged: (v) => setState(() => options[x] = v),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "5. FILE NAME & METADATA",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          ...[
            "File Name",
            "Artist",
            "Album / Project",
            "Genre",
            "Description",
            "Tags",
          ].map(
            (x) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                decoration: InputDecoration(
                  labelText: x,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF25EDFF)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "6. EXPORT DESTINATION",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          ...["Download to Device", "Save to Library", "Custom Location"].map(
            (x) => GestureDetector(
              onTap: () => setState(() => selectedDestination = x),
              child: Card(
                color: selectedDestination == x
                    ? const Color(0xFF263017)
                    : const Color(0xFF0A1930),
                child: ListTile(
                  title: Text(x),
                  leading: const Icon(
                    Icons.folder_outlined,
                    color: Color(0xFF25EDFF),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "PREVIEW & EXPORT HISTORY",
            style: TextStyle(
              color: Color(0xFF25EDFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Icon(Icons.graphic_eq, color: Color(0xFF25EDFF), size: 65),
          const SizedBox(height: 16),
          const FilledButton(
            onPressed: null,
            child: Text("EXPORT NOW - ENGINE PENDING"),
          ),
          const SizedBox(height: 24),
          const Text(
            'EXPORT ENGINE PENDING',
            style: TextStyle(color: Color(0xFF25EDFF)),
          ),
        ],
      ),
    ),
  );
}
