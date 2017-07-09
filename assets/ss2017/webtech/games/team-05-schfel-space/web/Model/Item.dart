import 'Position.dart';

class Item extends Position {
  // Eindeutige ID des Objekts
  int _elementId;
  int get elementId => _elementId;
  // Wert um Gültigkeit des Objekts festzulegen
  int _valid;
  int get valid => _valid;


  Item(int x, int y, int elementID, int valid) :this._elementId = elementID, this._valid = valid, super(x, y) {

  }


  /*
  Dekrementiere Valid um 1
 */
  void decValid(){
    this._valid--;
  }

}