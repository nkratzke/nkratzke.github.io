import 'dart:html';
import '../../model/static/Enum.dart';
import '../PreGameController.dart';

/*provides button elements for the pre game view*/
class PGVButtons{
  /*reference to the class using this class for generating its button elements
  * including button logic*/
  PreGameController pgc;

  PGVButtons(PreGameController preGameController){
    pgc = preGameController;
  }

  /*creates a button element enabling the player to switch his faction.
  * also loading the fitting card selection*/
  ButtonElement beFaction([String s]){
    String temp = (s == null ? 'Fraktion: ' : s);
    ButtonElement reflux = new ButtonElement();

    if(pgc.getPlayer().getFaction() == FACTION.BLAU){
      reflux.innerHtml = temp + 'Blau';
    }
    else if(pgc.getPlayer().getFaction() == FACTION.ROT){
      reflux.innerHtml = temp  + 'Rot';
    }

    reflux.onClick.listen((Event e){
      pgc.getPlayer().deck.clear();
      if(pgc.getPlayer().getFaction() == FACTION.BLAU){
        pgc.getPlayer().setFraktion(FACTION.ROT);
        reflux.innerHtml = temp + 'Blau';
      }
      else if(pgc.getPlayer().getFaction() == FACTION.ROT){
        pgc.getPlayer().setFraktion(FACTION.BLAU);
        reflux.innerHtml = temp + 'Rot';
      }
      pgc.createCardSelection(pgc.getPlayer().getFaction());
      pgc.update();
    });
    return reflux;
  }

  /*creates a button element enabling the player to put
  * all cards from his deck back into the pool at once*/
  ButtonElement beDeleteDeck([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'Deck loeschen' : s;
    reflux.onClick.listen((Event e){
      pgc.getPlayer().deckInSelection();
      pgc.view.update();
    });
    return reflux;
  }

  /*creates a button element enabling the player to start the game.
  * checks players deck size and pops an alert window if
  * the players deck doesnt contain enough cards*/
  ButtonElement beStartGame([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'Spiel Starten' : s;
    reflux.onClick.listen((Event e) {
      if(pgc.getPlayer().deck.length < pgc.mc.settings.get('pgc_deckSizeMin')){
        window.alert('Das Deck muss mindestens ' + pgc.mc.settings.get('pgc_deckSizeMin').toString()+ 'Karten enthalten!');
      }else{
        pgc.getPlayer().buildHand(pgc.mc.settings.get('pgc_handSizePlayer'));
        pgc.nextPhase();
      }
    });
    return reflux;
  }

  /*creates a button element enabling the player to display a help
  * page instead of the deck build view*/
  ButtonElement beHelp([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'Help' : s;
    reflux.onClick.listen((Event e){
      pgc.view.myTable.children.clear();
      pgc.view.myTable.children.addAll(pgc.view.helpTable().children);
    });
    return reflux;
  }

  /*creates a button element enabling the player to switch back
  * to the deck build view from the help table*/
  ButtonElement beBack([String s]){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = s == null ? 'back' : s;
    reflux.onClick.listen((Event e){
      pgc.view.update();
    });
    return reflux;
  }
}