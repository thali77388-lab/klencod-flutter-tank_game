import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = TankGame();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<TankGame>(
        game: game,
        overlayBuilderMap: {
          'controls': (context, g) => Controls(game: g),
        },
        initialActiveOverlays: const ['controls'],
      ),
    ),
  ));
}

class TankGame extends FlameGame {
  late Tank tank;
  Vector2 direction = Vector2.zero();

  @override
  Color backgroundColor() => const Color(0xFF3B3B3B);

  @override
  Future<void> onLoad() async {
    tank = Tank(this)..position = Vector2(150, 300);
    add(tank);
  }
}

class Tank extends PositionComponent {
  final TankGame game;
  double facing = -pi / 2;
  final double speed = 140;

  Tank(this.game) : super(size: Vector2.all(56), anchor: Anchor.center);

  @override
  void update(double dt) {
    final d = game.direction;
    if (d.length2 > 0) {
      facing = atan2(d.y, d.x);
      position += d.normalized() * speed * dt;
      position.clamp(Vector2.all(30), game.size - Vector2.all(30));
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 22), width: 60, height: 22),
      Paint()..color = const Color(0x55000000),
    );
    _body(canvas, c.translate(0, 10), const Color(0xFF1B5E20));
    _body(canvas, c.translate(0, 5), const Color(0xFF2E7D32));
    _body(canvas, c, const Color(0xFF4CAF50));
  }

  void _body(Canvas canvas, Offset center, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(facing);
    final p = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 44, height: 36),
        const Radius.circular(6),
      ),
      p,
    );
    canvas.drawRect(const Rect.fromLTWH(0, -4, 34, 8), p);
    canvas.drawCircle(Offset.zero, 12, p);
    canvas.restore();
  }
}

class Controls extends StatelessWidget {
  final TankGame game;
  const Controls({super.key, required this.game});

  Widget _btn(IconData icon, Vector2 dir) {
    return GestureDetector(
      onTapDown: (_) => game.direction = dir.clone(),
      onTapUp: (_) => game.direction = Vector2.zero(),
      onTapCancel: () => game.direction = Vector2.zero(),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: _btn(Icons.keyboard_arrow_up, Vector2(0, -1)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _btn(Icons.keyboard_arrow_down, Vector2(0, 1)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _btn(Icons.keyboard_arrow_left, Vector2(-1, 0)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _btn(Icons.keyboard_arrow_right, Vector2(1, 0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}