import '../Row.dart';
import '../static/Enum.dart';

/*implementing weather effects logic*/
class Weather{

  /*adding a weather effect to the given row
  * by calling the rows addWeather()-method*/
  void applyEffect(Row r){
    r.addWeather(EFFECTS.WEATHER);
  }
}