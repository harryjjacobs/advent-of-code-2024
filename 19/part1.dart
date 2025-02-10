import 'dart:io';

class PuzzleInput {
  Set<String> patterns;
  Set<String> designs;

  PuzzleInput(this.patterns, this.designs);
}

Future<(Set<String>, Set<String>)> parseFile(String fileName) async {
  final file = File(fileName);

  final lines = await file.readAsLines();

  final patterns = lines.first.split(", ").toSet();
  final designs = lines.skip(2).takeWhile((line) => line.isNotEmpty).toSet();

  return (patterns, designs);
}

Iterable<String> findStartingPatterns(String design, Set<String> patterns) {
  return patterns.where((pattern) => design.startsWith(pattern));
}

String cacheKey(String design, String pattern) {
  return design + "|" + pattern;
}

bool? checkCache(Map<String, bool> cache, String design, String pattern) {
  final key = cacheKey(design, pattern);
  if (cache.containsKey(key)) {
    return cache[key];
  }
  return null;
}

void setCache(
    Map<String, bool> cache, String design, String pattern, bool value) {
  final key = cacheKey(design, pattern);
  cache[key] = value;
}

bool checkDesign(String design, Set<String> patterns, Map<String, bool> cache) {
  if (design.isEmpty) {
    return true;
  }
  for (var pattern in findStartingPatterns(design, patterns)) {
    final remainingDesign = design.substring(pattern.length);
    final result = checkCache(cache, remainingDesign, pattern) ??
        checkDesign(remainingDesign, patterns, cache);
    setCache(cache, remainingDesign, pattern, result);
    if (result) {
      return true;
    }
  }
  return false;
}

void main() async {
  var (patterns, designs) = await parseFile('input');
  print(designs
      .map((design) => checkDesign(design, patterns, {}))
      .fold<int>(0, (count, valid) => count + (valid ? 1 : 0)));
}
