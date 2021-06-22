import 'mixins.dart';
import 'extensions.dart';
import 'position.dart';
import '../utils/script.dart';
import 'script.dart';

//
// Detect objects entering and exiting
//
@HTBinding()
class Area extends Position {
  Script? onEnterScript;
  Script? onExitScript;
  List<String> entityLayers = []; // the list of entity layers to check for 'collisions' that might trigger this
  bool enabled = true;

  Future<void> fromData(dynamic data) async {
    super.fromData(data);
    enabled = data['enabled'] ?? this.enabled;
    addChildIf(onEnterScript = scriptComponentFromString('onEnterScript', data['onEnterScript']));
    addChildIf(onExitScript = scriptComponentFromString('onExitScript', data['onExitScript']));
  }
}

Future<Area> areaComponentFromData(dynamic data) async {
  final comp = new Area();
  await comp.fromData(data);
  return comp;
}