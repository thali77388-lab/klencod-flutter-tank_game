import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: TankGame()));
}

class TankGame extends FlameGame with DragCallbacks {
  late Tank tank;

  @override
  Future<void> onLoad() async {
    tank = Tank()..position = Vector2(100, 200);
    add(tank);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    tank.position += event.localDelta;
  }
}

class Tank extends PositionComponent {
  Tank() : super(size: Vector2.all(48));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = Colors.green);
  }
}