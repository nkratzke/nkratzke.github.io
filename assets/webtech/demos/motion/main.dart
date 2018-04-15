import 'dart:html';
import 'MotionView.dart';
import 'dart:async';
import 'dart:math';

void main() {

  document.body.requestFullscreen;

  final alpha = querySelector('#alpha');
  final beta = querySelector('#beta');
  final gamma = querySelector('#gamma');

  final view = new MotionView();

  Circle area = new Circle(view.center_x, view.center_y, view.width / 4, view);
  Circle ball = new Circle(view.center_x, view.center_y, view.width / 8, view);

  view.update(area, ball);

  final random = new Random();

  // React on timers
  //
  final timer = new Timer.periodic(new Duration(milliseconds: 30), (_) {
    if (!area.isIn(ball)) ball.item = false;
    if (!area.isInDanger(ball)) ball.grow(-1.0);
    if (area.isInDanger(ball)) ball.grow(0.25);
    if (area.isOut(ball)) ball.grow(0.5);
    view.update(area, ball);
  });

  // Activate items
  final item = new Timer.periodic(new Duration(seconds: 1), (_) {
    if (area.isIn(ball)) ball.item = true;
  });

  // Move timer
  final move = new Timer.periodic(new Duration(milliseconds: 500), (_) {
    final ax = random.nextDouble() * 20 - 10;
    final ay = random.nextDouble() * 20 - 10;
    area.move(ax, ay);
    ball.move((area.x - ball.x) / 20, (area.y - ball.y) / 20);
  });

  // React on device orientation events.
  //
  window.onDeviceOrientation.listen((ev) {
    alpha.text = "Alpha: ${ev.alpha}°";
    beta.text = "Beta: ${ev.beta}°";
    gamma.text = "Gamma: ${ev.gamma}°";
  });

  // Gameover
  final gameover = new Timer.periodic(new Duration(milliseconds: 15), (_) {
    if (1.25 * area.radius < ball.radius) {
      timer.cancel();
      move.cancel();
      item.cancel();
    }
  });
}
