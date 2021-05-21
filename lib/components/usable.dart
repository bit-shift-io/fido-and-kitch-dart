import 'package:flame/components.dart';

class Usable extends PositionComponent {
  Future<void> fromYaml(dynamic yaml) async {
  }
}

Future<Usable> usableComponentFromYaml(dynamic yaml) async {
  final comp = new Usable();
  await comp.fromYaml(yaml);
  return comp;
}