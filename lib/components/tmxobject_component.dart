import 'package:tiled/tiled.dart' as t;
import 'mixins.dart';
import 'package:flame/components.dart';

class TmxObjectComponent extends Component with HasName {
  t.TmxObject object;

  Future<void> fromData(dynamic data) async {
    name = data['name'];
    object = data['object'];
  }
}


Future<TmxObjectComponent> tmxObjectComponentFromData(dynamic data) async {
  final comp = new TmxObjectComponent();
  await comp.fromData(data);
  return comp;
}