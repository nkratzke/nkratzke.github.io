import 'Shuttle.dart';

class Enemy extends Shuttle{
  // Punkte die man für Zerstörung des Gegners bekommt
  int _points;
  int get points => _points;
  // Wert um Gültigkeit des Objekts festzulegen
  int _valid;
  int get valid => _valid;
  Enemy(x, y, l, id, points, valid) : this._points = points,this._valid = valid, super(x, y, l, id);


/*
  Dekrementiere Valid um 1.
 */
  void decValid(){
    this._valid--;
  }


}