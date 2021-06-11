import 'package:tiled/tiled.dart' as t;
import 'mixins.dart';
import 'package:flame/components.dart';

class TiledObjectComponent extends Component with HasName {
  t.TiledObject object;

  Future<void> fromData(dynamic data) async {
    name = data['name'];
    object = data['object'];
  }
}


Future<TiledObjectComponent> tiledObjectComponentFromData(dynamic data) async {
  final comp = new TiledObjectComponent();
  await comp.fromData(data);
  return comp;
}