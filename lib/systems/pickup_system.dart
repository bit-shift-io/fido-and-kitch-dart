import 'package:fido_and_kitch/components/position.dart';

import '../components/entity.dart';
import '../components/inventory.dart';
import '../components/pickup.dart';
import 'package:flame/components.dart';

import '../components/extensions.dart';
import '../components/system.dart';
import '../game.dart';

class PickupSystem extends System with HasGameRef<Game> {
  @override
  void update(double delta) {
    // TODO: fix me, chnage make a pickup entity?
    return; 

    // TODO: for each player, see if they intersect any pickups
    final players = gameRef.players;
    final pickups = gameRef.getEntities<Entity>('Pickups');

    for (final player in players) {
      final playerRect = player.position!.toRect();
      for (final pickup in pickups) {
        final pickupRect = pickup.findFirstChildByClass<Position>()!.toRect();
        if (playerRect.overlaps(pickupRect)) {
          gameRef.remove(pickup);
          pickup.removeFromEntityLists(gameRef);

          Inventory? playerInventory = player.findFirstChildByClass<Inventory>();
          if (playerInventory != null) {
            List<Pickup> pickupComponents = pickup.findChildrenByClass<Pickup>();
            for (final pc in pickupComponents) {
              print('Player picked up ${pc.itemName}');
              playerInventory.addItem(pc.itemName, count: pc.itemCount);
            }
          }
        }
      }
    }
  }
}