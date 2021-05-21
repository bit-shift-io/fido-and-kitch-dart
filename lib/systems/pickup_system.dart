

import 'package:flame/components.dart';

import '../components/system.dart';
import '../game.dart';

class PickupSystem extends System with HasGameRef<MyGame> {
  @override
  void update(double delta) {
    // TODO: for each player, see if they intersect any pickups
    final players = gameRef.players;
    final pickups = gameRef.getEntities<PositionComponent>('Pickups');

    for (final player in players) {
      final playerRect = player.toRect();
      for (final pickup in pickups) {
        final pickupRect = pickup.toRect();
        if (playerRect.overlaps(pickupRect)) {
          print("Give pickup to player! - need a pickupComponent to configure what item to give the player");
          gameRef.remove(pickup);
        }
      }
    }
  }
}