import '../controller/MasterController.dart';
import 'static/CardData.dart';
import 'static/Enum.dart';
import 'cards/Card.dart';
import 'ai/AI.dart';
import 'Field.dart';
import 'Row.dart';
import 'Player.dart';
import 'effects/Horn.dart';
import 'effects/MoraleBoost.dart';
import 'effects/Brotherhood.dart';
import 'effects/Spy.dart';
import 'effects/Healer.dart';
import 'effects/Weather.dart';
import 'effects/GoodWeather.dart';
import 'dart:html';

class Game{
  /*reference to the master controller of the game*/
  MasterController mc;
  /*reference to the class holding the rows of player and AI*/
  Field            field;
  /*references to the player and AI objects*/
  Player           player;
  AI               ai;
  /*reference to the object holding all known cards*/
  CardData         cardData;
  /*list using to save each rounds result*/
  List<int>        results;
  /*reference to the class implementing the horn effect*/
  Horn             eHorn;
  /*reference to the class implementing the morale boost effect*/
  MoraleBoost      eMoraleBoost;
  /*reference to the class implementing the brotherhood effect*/
  Brotherhood      eBrotherhood;
  /*reference to the class implementing the spy effect*/
  Spy              eSpy;
  /*reference to the class implementing the healer effect*/
  Healer           eHealer;
  /*reference to the class implementing the weather effect*/
  Weather          eWeather;
  /*reference to the class implementing the good weather effect*/
  GoodWeather      eGoodWeather;

  Game(MasterController masterController){
    mc            = masterController;
    cardData      = new CardData(mc);
    field         = new Field(this);
    results       = new List<int>();
    eHorn         = new Horn();
    eMoraleBoost  = new MoraleBoost();
    eBrotherhood  = new Brotherhood();
    eSpy          = new Spy(mc.settings.get('spyDrawMax'));
    eHealer       = new Healer();
    eWeather      = new Weather();
    eGoodWeather  = new GoodWeather();
  }

  void reset(){
    player.cardSelection.clear();
    field.reset();
    results.clear();
  }

  //****//
  //Misc//
  //****//
  /*sums up APs from a number of rows by invoking each rows
  * sumAP-function*/
  int _sumAP(List<Row> rows){
    int reflux = 0;
    rows.forEach((Row r) => reflux += r.sumAP());
    return reflux;
  }
  int sumPlayerAP(){
    return _sumAP(field.rowsPlayer.values);
  }
  int sumAiAP(){
    return _sumAP(field.rowsAI.values);
  }

  /*Handles playing a card from player or AI. does not remove cards from
  * any pile of player or ai*/
  void playCard(Card k, Player s) {
    //******//
    //PLAYER//
    //******//
    print('playCard called: ' + k.name + ' / ' + s.runtimeType.toString());
    if(s == player){
      print('playCard for PLAYER');
      Row target = field.rowsPlayer[k.rowTypes[0]];

      if(k.effects.isEmpty){
        target.addCard(k);
        target.sumAP();
      }else{
        EFFECTS effekt = k.effects[0];
        if(effekt == EFFECTS.BROTHERHOOD || effekt == EFFECTS.HORN || effekt == EFFECTS.MORALEBOOST){
          target.addCard(k);
          target.sumAP();
        }
        if(effekt == EFFECTS.SPY){
          target = field.rowsAI[k.rowTypes[0]];
          target.addCard(k);
          eSpy.applyEffect(player.hand, player.deck);
        }
        if(effekt == EFFECTS.HEALER){
          target.addCard(k);

          var sw = mc.gc.view;
          DivElement div = k.basicDivElement();
          div.classes.add('karte');
          div.classes.add('kartenid'+k.id);
          switch(k.rowTypes[0]){
            case(ROWTYPE.SIEGE):
              sw.updateRowPlayerSiege();
              break;
            case(ROWTYPE.DIST):
              sw.updateRowPlayerDist();
              break;
            case(ROWTYPE.CLOSE):
              sw.updateRowPlayerClose();
              break;
            default:
              break;
          }

          if(mc.gc.divPlayerDiscard_playable().isEmpty){
            mc.aiTurn();
            sw.update();
          }else{
            eHealer.applyEffect(player.discard, mc, true);
          }
          print('Heiler gespielt, geh weinen!');
        }
        if(effekt == EFFECTS.WEATHER){
          eWeather.applyEffect(target);
          target = field.rowsAI[k.rowTypes[0]];
          eWeather.applyEffect(target);
          player.discard.add(k);
          print('wetterkate gespielt');
        }
        if(effekt  == EFFECTS.GOODWEATHER){
          eGoodWeather.applyEffect(this);
          player.discard.add(k);
          print('gutes wetter gespielt');
        }
      }
    }
    //**//
    //AI//
    //**//
    if(s == ai){
      print('playCard for AI');
      Row target = field.rowsAI[k.rowTypes[0]];
      if(k.effects.isEmpty){
        target.addCard(k);
        target.sumAP();
      }else{
        EFFECTS effekt = k.effects[0];
        if(effekt == EFFECTS.BROTHERHOOD || effekt == EFFECTS.HORN || effekt == EFFECTS.MORALEBOOST){
          target.addCard(k);
          target.sumAP();
        }
        if(effekt == EFFECTS.SPY){
          print('beware the ai spy!');
          target = field.rowsPlayer[k.rowTypes[0]];
          target.addCard(k);
          eSpy.applyEffect(ai.hand, ai.deck);
        }
        if(effekt == EFFECTS.HEALER){
          target.addCard(k);
          eHealer.applyEffect(ai.discard, mc, false);
          print('Heiler gespielt, geh weinen!');
        }
        if(effekt == EFFECTS.WEATHER){
          eWeather.applyEffect(target);
          target = field.rowsPlayer[k.rowTypes[0]];
          eWeather.applyEffect(target);
          player.discard.add(k);
          print('wetterkate gespielt');
        }
        if(effekt  == EFFECTS.GOODWEATHER){
          eGoodWeather.applyEffect(this);
          ai.discard.add(k);
          print('gutes wetter gespielt');
        }
      }
    }
  }
}