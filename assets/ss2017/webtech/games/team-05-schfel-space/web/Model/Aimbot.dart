import 'Item.dart';

class Aimbot extends Item {
  // Die Zeit für den Aimbot in sekunden
  int _time;
  int get time=>_time;


  Aimbot(int x, int y, int elementID, int valid, int time) : super(x, y, elementID, valid) {
    this._time = time;
  }




}