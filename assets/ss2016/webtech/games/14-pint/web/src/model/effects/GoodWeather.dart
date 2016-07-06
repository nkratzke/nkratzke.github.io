import '../Game.dart';
import '../Row.dart';

/*implementing good weather effect logic*/
class GoodWeather{

  /*removing all weather effects from the field by calling
  * the clearWeather()-method of all rows*/
  void applyEffect(Game s){
    s.field.rowsPlayer.values.forEach((Row r) => r.clearWeather());
    s.field.rowsAI.values.forEach((Row r) => r.clearWeather());
  }
}