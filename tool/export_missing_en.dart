import "dart:convert";
import "dart:io";

void main() {
  final Map<String, dynamic> en =
      jsonDecode(File("assets/l10n/en.json").readAsStringSync(encoding: utf8))
          as Map<String, dynamic>;
  final List<String> keys =
      File("tool/missing_keys.txt").readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();

  final Map<String, String> out = {};
  for (final String k in keys) {
    out[k] = en[k]?.toString() ?? "";
  }

  final String json = const JsonEncoder.withIndent("  ").convert(out);
  File("tool/l10n_supplement/en_values.json").writeAsStringSync("$json\n");
  stdout.writeln("Exported ${out.length} keys");
}
