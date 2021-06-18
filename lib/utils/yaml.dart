import 'package:flame/game.dart';
import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";

dynamic loadYamlFromFile(String fileName, { Map<String, dynamic>? substitutions }) async {
  String fileContents = await s.rootBundle.loadString(fileName);
  if (substitutions != null) {
    substitutions.forEach((key, value) { 
      String keyStr = '\${$key}';
      String valueStr = value;
      fileContents = fileContents.replaceAll(keyStr, valueStr);
    });
  }
  try {
    final mapData = loadYaml(fileContents);
    return mapData;
  } catch (e) {
    print('Failed to load $fileName:');
    print(e);
  }
  return null;
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

Vector2? vector2FromData(dynamic yaml) {
  if (yaml == null) {
    return null;
  }
  double x = yaml[0].toDouble();
  double y = yaml[1].toDouble();
  return Vector2(x, y);
}

// given some yaml data, convert to a string list
List<String> toStringList(dynamic data) {
  List<String> list = [];
  if (data is YamlList) {
    for (final item in data) {
      list.add(item);
    }
    return list;
  }

  list.add(data);
  return list;
}
