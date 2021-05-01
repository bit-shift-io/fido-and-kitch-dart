import 'dart:ui';
import 'package:flame/components/component.dart';

class R {
  Rect rect;
  Color color;
  PaintingStyle style;

  R(this.rect, this.color, this.style);
}

class Debug extends Component {

  List<R> rects = <R>[];

  drawRect(Rect rect, Color color, PaintingStyle style) {
    rects.add(R(rect, color, style));
  }

  @override
  void render(Canvas c) {
    for (final r in rects) {
      c.drawRect(r.rect, Paint() ..color = r.color ..style = r.style);
    }
    clear();
  }

  @override
  void update(double t) {
  }

  void clear() {
    rects.clear();
  }

}