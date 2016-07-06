import 'dart:html';
import '../AfterGameController.dart';

/*providing button elements for the after game view*/
class AGVButtons{
  /* reference to the controller using this class for generating its
   * button elements including button logic*/
  AfterGameController agc;

  AGVButtons(AfterGameController afterGameController){
    agc = afterGameController;
  }

  /*generates a button element enabling the player to restart the game.
  * invoking after game controllers restart method.*/
  ButtonElement beNeustart(){
    return new ButtonElement()..innerHtml = 'Neustart!'
      ..onClick.listen((Event e) => agc.restart());
  }
}