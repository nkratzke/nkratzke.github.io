import '../MasterController.dart';
import '../../model/static/Enum.dart';
import 'dart:html';

/*provides html-elements for the login phase*/
class MVButtons{
  /*reference to the class using this class for generating its button elements
  * including button logic*/
  MasterController mc;

  MVButtons(MasterController masterController){
    mc = masterController;
  }

  /*generates a button element enabling the player to log in to
  * the gamekey-service by invoking the player load method.
  * does not check gamekey availability*/
  ButtonElement beLogin([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'Anmelden' : s;
    reflux.onClick.listen((Event e)async{
      print('vorLaden');
      bool temp = true;
      temp = await mc.playerLoad();
      if(temp){
        print('nachLaden');
        print(mc.getPlayer().valuesMatrix());
        mc.update(GAMEPHASE.PREPAREDECK, false);
      }
    });
    return reflux;
  }

  /*generates a button element enabling the player to register
  * at the gamekey-service with a username and password*/
  ButtonElement beRegister([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'Registrieren' : s;
    reflux.onClick.listen((Event e)async{
      await mc.playerRegister();
    });
    return reflux;
  }

  /*generates a button element enabling the player to play offline.
  * sets player name and password both to 'Offline'.
  * invokes the player load method and updates the master controller
  * to the next (pre game) phase*/
  ButtonElement bePlayOffline([String s]){
    ButtonElement reflux = new ButtonElement();

    reflux.innerHtml = s == null ? 'Offline Spielen' : s;
    reflux.onClick.listen((Event e) async {
      if(mc.view.ieUsername.value.length > 0){
        mc.getPlayer().name = 'Offline';
        mc.getPlayer().password = 'Offline';
        /*let the load method handle wether it can reach the gamekey or not*/
        await mc.playerLoad();
        print(mc.getPlayer().valuesMatrix());
        mc.update(GAMEPHASE.PREPAREDECK, false);
      }
    });
    return reflux;
  }

  /*generates an input element enabling the player to enter his name*/
  InputElement ieUsername([String s]){
    InputElement reflux = new InputElement();
    reflux.placeholder = s == null ? 'Platzthalter' : s;
    mc.view.ieUsername = reflux;
    return reflux;
  }

  /*generates an input element enabling the player to enter his password*/
  InputElement iePassword([String s]){
    InputElement reflux = new InputElement();
    reflux.placeholder = s == null ? 'Passwort' : s;
    mc.view.iePassword = reflux;
    return reflux;
  }
}