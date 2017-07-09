import 'Position.dart';

class Shot extends Position {
  // Eindeutige ID des Objects
   int _elementId;
   int get elementId => _elementId;
  // Wert um gültigkeit des Objekts festzulegen
   int _valid;
   int get valid => _valid;
   // Wert um zu wissen, ob der Schuss Gegner suchen soll
   bool _isAimbot;
   bool get isAimbot => _isAimbot;

  /*
  Constructor um einen Shot für einen Gegner zu erstellen.
   */
  Shot.enemy(int x, int y, int id) : super(x, y) {
    this._valid = 1;
    this._elementId = id;
    _isAimbot = false;
  }
  /*
  Constructor um einen Shot von dem Spielershuttle zu erstellen
   */
  Shot.player(int x, int y, int id, bool isAimbot) : super(x, y) {
    this._valid = 1;
    this._elementId = id;
    this._isAimbot = isAimbot;
  }

/*
Dekrementiere Gültigkeit(valid) um 1;
 */
  void decValid(){
    this._valid--;
  }


}