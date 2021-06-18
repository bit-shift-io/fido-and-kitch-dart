import 'mixins.dart';
import 'position.dart';
import '../utils/script.dart';

//
// Detect objects entering and exiting
//
@HTBinding()
class Area extends Position {
  String onEnterScript = '';
  String onExitScript = '';
  List<String> entityLayers = []; // the list of entity layers to check for 'collisions' that might trigger this

  Future<void> fromData(dynamic data) async {
    super.fromData(data);
  }
}

Future<Area> areaComponentFromData(dynamic data) async {
  final comp = new Area();
  await comp.fromData(data);
  return comp;
}