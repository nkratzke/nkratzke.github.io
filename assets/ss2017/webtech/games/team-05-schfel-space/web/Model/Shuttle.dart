import 'Position.dart';

class Shuttle extends Position{
  // Anzahl an Leben die das Schiff besitzen soll
  int _life;
  int get life => _life;
  set life(int value) => _life = value;
  // Eindeutige ID des Objekts
  int _elementId;
  int get elementId => _elementId;

  Shuttle(int x, int y, int life, int id) : this._life = life, this._elementId = id, super(x, y);

  /*
  Dekrementiere Leben um 1
   */
  void decLife(){
    _life--;
  }

  /*
  Erhöhe leben um 1
   */
  void incLife(){
    this._life++;
  }


}