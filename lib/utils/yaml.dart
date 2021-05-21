import 'package:flame/game.dart';
import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";

dynamic loadYamlFromFile(String fileName) async {
  final data = await s.rootBundle.loadString(fileName);
  final mapData = loadYaml(data);
  return mapData;
}

dynamic yamlFirstWhere(dynamic yaml, Function where) {
  for (var y in yaml) {
    final r = where(y);
    if (r == true) {
      return y;
    }
  }

  return null;
}

Vector2 vector2FromYaml(dynamic yaml) {
  if (yaml == null) {
    return null;
  }
  double x = yaml[0].toDouble();
  double y = yaml[1].toDouble();
  return Vector2(x, y);
}
