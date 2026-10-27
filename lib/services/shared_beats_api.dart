import "dart:convert";
import "dart:typed_data";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class SharedBeatInfo {
  final String id;
  final String name;
  final int sizeBytes;
  const SharedBeatInfo(this.id, this.name, this.sizeBytes);
  factory SharedBeatInfo.fromJson(Map<String, dynamic> j) => SharedBeatInfo(
    j["id"] as String,
    j["name"] as String,
    (j["size_bytes"] as num?)?.toInt() ?? 0,
  );
}

class SharedBeatsApi {
  static const baseUrl =
      "https://ic391-defense-command.tail49e2f2.ts.net:10000";
  static const _key = "999_common_beats_access_token";
  static Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString(_key);
  static Future<bool> get signedIn async => await token() != null;

  static Future<void> login(String username, String password) async {
    final r = await http.post(
      Uri.parse("$baseUrl/v1/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    if (r.statusCode != 200) {
      throw Exception("Login failed (${r.statusCode}): ${r.body}");
    }
    final t = (jsonDecode(r.body) as Map<String, dynamic>)["access_token"];
    if (t is! String || t.isEmpty) {
      throw Exception("No access token returned");
    }
    await (await SharedPreferences.getInstance()).setString(_key, t);
  }

  static Future<void> logout() async {
    final t = await token();
    try {
      if (t != null) {
        await http.post(
          Uri.parse("$baseUrl/v1/auth/logout"),
          headers: {"Authorization": "Bearer $t"},
        );
      }
    } finally {
      await (await SharedPreferences.getInstance()).remove(_key);
    }
  }

  static Future<Map<String, String>> _headers() async {
    final t = await token();
    if (t == null || t.isEmpty) {
      throw Exception("Sign in to access shared beats");
    }
    return {"Authorization": "Bearer $t"};
  }

  static Future<List<SharedBeatInfo>> listBeats() async {
    final r = await http.get(
      Uri.parse("$baseUrl/v1/beats"),
      headers: await _headers(),
    );
    if (r.statusCode != 200) {
      throw Exception("Library request failed (${r.statusCode})");
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return (j["beats"] as List)
        .map((e) => SharedBeatInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SharedBeatInfo> uploadBeat(String name, Uint8List bytes) async {
    if (bytes.length > 100 * 1024 * 1024) {
      throw Exception("Audio exceeds 100 MB");
    }
    final q = http.MultipartRequest("POST", Uri.parse("$baseUrl/v1/beats"));
    q.headers.addAll(await _headers());
    q.files.add(http.MultipartFile.fromBytes("file", bytes, filename: name));
    final streamed = await q.send().timeout(const Duration(minutes: 3));
    final r = await http.Response.fromStream(streamed);
    if (r.statusCode != 200) {
      throw Exception("Upload failed (${r.statusCode}): ${r.body}");
    }
    return SharedBeatInfo.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  static Future<Uint8List> downloadBeat(String id) async {
    final r = await http.get(
      Uri.parse("$baseUrl/v1/beats/$id/audio"),
      headers: await _headers(),
    );
    if (r.statusCode != 200) {
      throw Exception("Download failed (${r.statusCode})");
    }
    return r.bodyBytes;
  }
}
