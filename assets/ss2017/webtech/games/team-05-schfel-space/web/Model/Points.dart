import 'Item.dart';

class Points extends Item {
  /*
  Anzahl an punkte items die das Item geben soll.
   */
  int _points;
  int get points => _points;

  Points(int x, int y, int elementID, int valid, int points) : super(x, y, elementID, valid) {
    this._points = points;
  }

  /*
  Addiere die Points von dem Item auf den übergebenen Wert.
   */
  int incPoints(int points) {
    return points + this._points;
  }
}