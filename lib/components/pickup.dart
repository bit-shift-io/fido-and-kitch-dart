import 'package:flame/components.dart';

class Pickup extends PositionComponent {
  Future<void> fromYaml(dynamic yaml) async {
  }
}

Future<Pickup> pickupComponentFromYaml(dynamic yaml) async {
  final comp = new Pickup();
  await comp.fromYaml(yaml);
  return comp;
}