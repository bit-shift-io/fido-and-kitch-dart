import 'package:flame/components.dart';

class UsableComponent extends PositionComponent {
  String requiredItem;
  int requiredItemCount;
  String playerAnimationOnUse;

  Future<void> fromYaml(dynamic yaml) async {
    requiredItem = yaml['requiredItem'];
    requiredItemCount = yaml['requiredItemCount'] ?? 1;
    playerAnimationOnUse = yaml['playerAnimationOnUse'];
  }
}

Future<UsableComponent> usableComponentFromYaml(dynamic yaml) async {
  final comp = new UsableComponent();
  await comp.fromYaml(yaml);
  return comp;
}