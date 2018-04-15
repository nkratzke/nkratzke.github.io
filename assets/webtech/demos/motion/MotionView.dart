import 'dart:html';
import 'dart:math';

class Circle {

  double x, y, radius;
  double target;
  bool item = false;
  double dx = 0.0, dy = 0.0;
  MotionView view;

  Circle(this.x, this.y, this.radius, this.view) { this.target = this.radius; }

  int get top    => (this.y - this.radius).floor();
  int get bottom => (this.y + this.radius).floor();
  int get left   => (this.x - this.radius).floor();
  int get right  => (this.x + this.radius).floor();
  int get width  => (2 * this.radius).floor();
  int get height => (2 * this.radius).floor();

  void move(double dx, double dy) {
    this.dx = dx;
    this.dy = dy;
  }

  void update() {
    this.x += this.dx;
    this.y += this.dy;

    if (this.top < 0) this.y = this.radius;
    if (this.bottom > this.view.height - 1) this.y = this.view.height - 1 - this.radius;

    if (this.left < 0) this.x = this.radius;
    if (this.right > this.view.width - 1) this.x = this.view.width - 1 - this.radius;
  }

  void grow(double dr) {
    this.radius += dr;
    this.radius = max(this.target, this.radius);
    this.radius = min(this.view.size / 2, this.radius);
  }

  bool isInDanger(Circle other) {
    final dx = (this.x - other.x).abs();
    final dy = (this.y - other.y).abs();
    final dist = sqrt(dx * dx + dy * dy);
    return dist + other.radius > this.radius;
  }

  bool isOut(Circle other) {
    final dx = (this.x - other.x).abs();
    final dy = (this.y - other.y).abs();
    final dist = sqrt(dx * dx + dy * dy);
    return dist > this.radius;
  }

  bool isIn(Circle other) {
    final dx = (this.x - other.x).abs();
    final dy = (this.y - other.y).abs();
    final dist = sqrt(dx * dx + dy * dy);
    return dist + other.radius  < this.radius;
  }

}

class MotionView {

  final field = querySelector("#field");
  final over = querySelector("#over");
  final area = querySelector("#area");
  final ball = querySelector("#ball");

  int get width => window.innerWidth;
  int get height => window.innerHeight;
  int get size => min(this.width, this.height);
  double get center_x => this.width / 2;
  double get center_y => this.height / 2;

  void update(Circle a, Circle b) {

    a.update();
    b.update();

    if (b.radius > 1.25 * a.radius) {
      over.style.visibility = 'visible';
    }

    this.ball.classes.remove('item');
    if (b.item) {
      this.ball.classes.add('item');
    }

    final round = "${this.size}px";

    this.area.style.width="${a.width}px";
    this.area.style.height="${a.width}px";
    this.area.style.borderRadius=round;
    this.area.style.top="${a.top}px";
    this.area.style.left="${a.left}px";

    this.ball.style.top = "${b.top}px";
    this.ball.style.left = "${b.left}px";
    this.ball.style.width = "${b.width}px";
    this.ball.style.height = "${b.width}px";
    this.ball.style.borderRadius=round;

    this.ball.classes.remove('out');
    this.ball.classes.remove('danger');

    if (a.isInDanger(b)) this.ball.classes.add('danger');
    if (a.isOut(b)) this.ball.classes.add('out');
  }
}