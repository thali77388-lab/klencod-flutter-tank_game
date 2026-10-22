import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

const double worldW = 340;
const double worldH = 520;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TankScreen(),
  ));
}

class Floor extends PositionComponent {
  Floor() : super(size: Vector2(worldW, worldH));

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, worldW, worldH),
        Paint()..color = const Color(0xFF1B2A1F));
    final line = Paint()
      ..color = const Color(0xFF2E4A36)
      ..strokeWidth = 1;
    for (double x = 0; x <= worldW; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, worldH), line);
    }
    for (double y = 0; y <= worldH; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(worldW, y), line);
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, worldW, worldH),
      Paint()
        ..color = const Color(0xFF8BC34A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}

class Tank extends PositionComponent {
  final ValueNotifier<Offset> input;
  static const double speed = 130;

  Tank(this.input)
      : super(
          size: Vector2(44, 44),
          anchor: Anchor.center,
          position: Vector2(worldW / 2, worldH - 60),
        );

  @override
  void update(double dt) {
    final d = input.value;
    if (d != Offset.zero) {
      position.x += d.dx * speed * dt;
      position.y += d.dy * speed * dt;
      position.x = position.x.clamp(26.0, worldW - 26).toDouble();
      position.y = position.y.clamp(26.0, worldH - 26).toDouble();
      angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 8, 36, 40), const Radius.circular(6)),
      Paint()..color = Colors.black.withOpacity(0.45),
    );
    final track = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 2, 10, 40), const Radius.circular(3)),
        track);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(34, 2, 10, 40), const Radius.circular(3)),
        track);
    final tread = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 2;
    for (double y = 6; y < 42; y += 6) {
      canvas.drawLine(Offset(1, y), Offset(9, y), tread);
      canvas.drawLine(Offset(35, y), Offset(43, y), tread);
    }
    const bodyRect = Rect.fromLTWH(8, 4, 28, 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9CCC65), Color(0xFF33691E)],
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(19.5, -8, 5, 24), const Radius.circular(2)),
      Paint()..color = const Color(0xFF558B2F),
    );
    canvas.drawRect(const Rect.fromLTWH(18.5, -8, 7, 4),
        Paint()..color = const Color(0xFF33691E));
    canvas.drawCircle(
      const Offset(22, 22),
      9,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFDCEDC8), Color(0xFF689F38)],
        ).createShader(
            Rect.fromCircle(center: const Offset(22, 22), radius: 9)),
    );
  }
}

class TankGame extends FlameGame {
  final ValueNotifier<Offset> input;
  TankGame(this.input);

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    add(Floor());
    add(Tank(input));
  }
}

class TankScreen extends StatefulWidget {
  const TankScreen({super.key});

  @override
  State<TankScreen> createState() => _TankScreenState();
}

class _TankScreenState extends State<TankScreen> {
  final ValueNotifier<Offset> input = ValueNotifier(Offset.zero);
  late final TankGame game = TankGame(input);

  Widget _btn(IconData icon, Offset dir) {
    return Listener(
      onPointerDown: (_) => input.value = dir,
      onPointerUp: (_) => input.value = Offset.zero,
      onPointerCancel: (_) => input.value = Offset.zero,
      child: Container(
        width: 68,
        height: 68,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF2E4A36),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8BC34A), width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B120D),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateX(0.65),
                    child: SizedBox(
                      width: worldW,
                      height: worldH,
                      child: GameWidget(game: game),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _btn(Icons.keyboard_arrow_up, const Offset(0, -1)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _btn(Icons.keyboard_arrow_left, const Offset(-1, 0)),
                      const SizedBox(width: 68),
                      _btn(Icons.keyboard_arrow_right, const Offset(1, 0)),
                    ],
                  ),
                  _btn(Icons.keyboard_arrow_down, const Offset(0, 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}