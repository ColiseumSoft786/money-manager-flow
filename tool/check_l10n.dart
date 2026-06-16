import "dart:convert";
import "dart:io";

void main() {
  final Directory dir = Directory("assets/l10n");
  final Map<String, Map<String, String>> langs = {};

  for (final File f in dir.listSync().whereType<File>()) {
    if (!f.path.endsWith(".json")) continue;
    final String code = f.uri.pathSegments.last.replaceAll(".json", "");
    langs[code] = (jsonDecode(f.readAsStringSync(encoding: utf8))
            as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()));
  }

  final Map<String, String> en = langs["en"]!;
  final Set<String> enKeys = en.keys.toSet();

  final Set<String> missingInAll = enKeys.toSet();
  for (final MapEntry<String, Map<String, String>> entry in langs.entries) {
    if (entry.key == "en") continue;
    missingInAll.removeAll(entry.value.keys.toSet());
  }

  // Keys missing in at least one non-en locale
  final Set<String> missingAny = <String>{};
  for (final MapEntry<String, Map<String, String>> entry in langs.entries) {
    if (entry.key == "en") continue;
    missingAny.addAll(enKeys.difference(entry.value.keys.toSet()));
  }

  stdout.writeln("en.json keys: ${enKeys.length}");
  stdout.writeln("missing in ALL non-en: ${missingInAll.length}");
  stdout.writeln("missing in ANY non-en: ${missingAny.length}");

  final List<String> sorted = missingAny.toList()..sort();
  for (final String k in sorted) {
    stdout.writeln("$k");
  }
}
