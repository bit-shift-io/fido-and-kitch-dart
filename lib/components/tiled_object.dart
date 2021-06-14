import '../tiled_map.dart' as t;
import 'mixins.dart';
import 'package:flame/components.dart';

class TiledObject extends Component with HasName {
  t.TiledObject object;

  Future<void> fromData(dynamic data) async {
    name = data['name'];
    object = data['object'];
  }
}


Future<TiledObject> tiledObjectComponentFromData(dynamic data) async {
  final comp = new TiledObject();
  await comp.fromData(data);
  return comp;
}