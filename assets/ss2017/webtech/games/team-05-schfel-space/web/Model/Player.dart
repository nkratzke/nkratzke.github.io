import 'Shuttle.dart';

class Player extends Shuttle{
  // Maximale Anzahl an leben
  int _maxlife;

  // Position die der Spieler einnehmen soll
  int _xTarget;
  int get xTarget => _xTarget;

  Player(int x, int y, int life, int id) :  super(x, y, life, id) {
    _maxlife = life;
  }

  /*
  Setzen der Position die angenommen werden soll
   */
  void setXTarget(int xTarget) {
    this._xTarget = xTarget;
  }

  /*
  Incrementiere Leben des Spielers wenn Leben kleiner als maximale anzahl an leben ist
   */
  void incLife() {
    if (life < _maxlife){
      life++;
    }
  }

}