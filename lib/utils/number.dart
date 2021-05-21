

import 'package:flame/game.dart';

class Int2 {
  Int2(this.x, this.y);
  Int2.fromVector2(Vector2 v) { x = v.x.round(); y = v.y.round(); }

  Int2 operator +(Int2 rhs) => Int2(x + rhs.x, y + rhs.y);
  
  Vector2 toVector2() => Vector2(x.toDouble(), y.toDouble());

  int x = 0;
  int y = 0;
}

List<int> range(start, end) {
  return new List<int>.generate(end - start, (i) => start + i + 1);
}