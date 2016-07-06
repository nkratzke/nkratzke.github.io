
import 'dart:async';
import 'dart:html';

import 'dart:convert'; //JSON

import '../model/cards/Card.dart';
import '../model/cards/Unit.dart';
import '../model/cards/Hero.dart';
import '../model/static/Enum.dart';


class FileLoader {

  final String unitsURI   = "Einheiten.json";
  final String heroesURI      = "Helden.json";
  final String weatherURI      = "Wetter.json";
  final String preferencesURI = "preferences.json";

  /* returns the settings from the preferences file
   */
  Future<Map> getSettings() async {
    try {
      Map pref = JSON.decode(await HttpRequest.getString(preferencesURI));
      String newPlayerFraction = pref['mc_newPlayerFaction'];
      pref['mc_newPlayerFaction'] = identifyFaction(newPlayerFraction);
      String newAIFraction = pref['mc_newAIFaction'];
      pref['mc_newAIFaction'] = identifyFaction(newAIFraction);
      return pref;
    } catch(exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }
    return new Map();
  }

  /* returns a list of all existing cards
   */
  Future cards()async {
    List<Card> cardList = <Card>[];
    List unitsList = JSON.decode(await HttpRequest.getString(unitsURI));
    List heroList = JSON.decode(await HttpRequest.getString(heroesURI));
    List weatherList = JSON.decode(await HttpRequest.getString(weatherURI));

    for(int i =0; i<unitsList.length;i++)
      cardList.add(createHeroOrUnit(unitsList[i],/*istHeld*/ false));
    for(int i =0; i<heroList.length;i++)
      cardList.add(createHeroOrUnit(heroList[i],/*istHeld*/ true));

    for(int i =0; i<weatherList.length;i++)
      cardList.add(createHeroOrUnit(weatherList[i],/*istHeld*/ true));

    return cardList;
  }

  /* Creates a card
   * @param entity a json description of a card
   * @param isHero bool which says if the card is a normal unit or a hero
   */
  Card createHeroOrUnit(Map entity, bool isHero){

    String id = entity['id'].toString();

    FACTION faction = identifyFaction(entity['Fraktion'].toString());

    //Bis jetzt hat jede Card nur max 1 Effekt
    List<EFFECTS> effects = (createEffect((entity['Effekte'])) == null) ? [] : [createEffect((entity['Effekte']))];
    List<ROWTYPE> canBePut = identifyRow(entity['Reihe (kannLiegen)']) == null ? [] : [identifyRow(entity['Reihe (kannLiegen)'])];
    int apCurrent = entity['AP'];
    String name = entity['Name'];
    int level = 0;
    if (entity['level'] != null) {
      level = entity['level'];
    }
    if (isHero) {
      return new Hero(id, name, level, faction, effects, canBePut, apCurrent, apCurrent);
    }
    else {
      return new Unit(id, name, level, faction, effects, canBePut, apCurrent, apCurrent);
    }

  }



  /* Returns the corresponding enum for a given rowtype encoded as a string
   */
  ROWTYPE identifyRow(String row){
    switch(row){
      case 'Nahkampf': return ROWTYPE.CLOSE;
      case 'Belagerung': return ROWTYPE.SIEGE;
      case 'Fernkampf' : return ROWTYPE.DIST;
      default : return null;
    }
    //return null;
  }

  /* Returns the corresponding enum for a given faction encoded as a string
   */
  FACTION identifyFaction(String faction){
    switch(faction){
      case 'blau'    : return FACTION.BLAU;
      case 'Blau'    : return FACTION.BLAU;
      case 'schwarz' : return FACTION.ROT;
      case 'Rot'     : return FACTION.ROT;
      case 'neutral' : return FACTION.NEUTRAL;
      default : return null;
    }
  }

  /* Returns the corresponding enum for a given effect encoded as a string
   */
  EFFECTS createEffect(String effect){
    switch(effect) {
      case 'Enge_Bindung': return EFFECTS.BROTHERHOOD;
      case 'Spion': return EFFECTS.SPY;
      case 'Heiler': return EFFECTS.HEALER;
      case 'Horn': return EFFECTS.HORN;
      case 'Moralschub': return EFFECTS.MORALEBOOST;
      case 'wetter' : return EFFECTS.WEATHER;
      case 'gutes_wetter' : return EFFECTS.GOODWEATHER;

      default:
        return null;
    }

  }

}