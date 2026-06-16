import "dart:convert";
import "dart:io";

/// Merges missing keys from en.json into every locale file.
/// Values come from tool/l10n_supplement/{locale}.json when present,
/// otherwise from en.json (fallback).
void main() {
  final Directory l10nDir = Directory("assets/l10n");
  final File enFile = File("assets/l10n/en.json");
  final Map<String, String> en = _load(enFile);

  final List<File> localeFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith(".json") && !f.path.endsWith("en.json"))
      .toList();

  for (final File file in localeFiles) {
    final String locale = file.uri.pathSegments.last.replaceAll(".json", "");
    final Map<String, String> localeMap = _load(file);
    final Map<String, String> supplement = _loadSupplement(locale);

    int added = 0;
    for (final MapEntry<String, String> entry in en.entries) {
      if (localeMap.containsKey(entry.key)) continue;
      localeMap[entry.key] = supplement[entry.key] ?? entry.value;
      added++;
    }

    final List<String> keys = localeMap.keys.toList()..sort();
    final Map<String, String> sorted = {for (final String k in keys) k: localeMap[k]!};
    file.writeAsStringSync(
      const JsonEncoder.withIndent("  ").convert(sorted),
      encoding: utf8,
    );
    stdout.writeln("$locale: added $added keys (total ${sorted.length})");
  }
}

Map<String, String> _load(File file) {
  return (jsonDecode(file.readAsStringSync(encoding: utf8)) as Map<String, dynamic>)
      .map((String k, dynamic v) => MapEntry(k, v.toString()));
}

Map<String, String> _loadSupplement(String locale) {
  final File file = File("tool/l10n_supplement/$locale.json");
  if (!file.existsSync()) return {};
  return _load(file);
}
