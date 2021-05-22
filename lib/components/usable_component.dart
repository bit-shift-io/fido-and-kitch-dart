import 'package:flame/components.dart';

class UsableComponent extends PositionComponent {
  Future<void> fromYaml(dynamic yaml) async {
  }
}

Future<UsableComponent> usableComponentFromYaml(dynamic yaml) async {
  final comp = new UsableComponent();
  await comp.fromYaml(yaml);
  return comp;
}