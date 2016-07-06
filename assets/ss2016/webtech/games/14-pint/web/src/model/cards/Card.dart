
import '../static/Enum.dart';
import 'dart:html';
import '../Player.dart';

/*represents the super class of all cards like units, heroes/weather-cards*/
abstract class Card{
  /*card level unique id of this card*/
  String        id,
  /*name/display name of this card*/
                name,
  /*text of this cards tooltip*/
                tooltipText;
  /*used for identifying cards placed in AIs rows for some reason (spy f.e.)*/
  Player        owner;
  /*level of this card*/
  int           level,
  /*delay of this cards tooltip (if necessary)*/
                tooltipDelay;
  /*faction of this card*/
  FACTION       faction;
  /*list of effects this card provides*/
  List<EFFECTS> effects;
  /*list of row types this card can be placed in*/
  List<ROWTYPE> rowTypes;

  Card(this.id, this.name, this.level, this.faction, this.effects, this.rowTypes);
  Card.empty();

  Card clone();
  String debugInfo();
  TableCellElement basicCellElement();
  DivElement basicDivElement();
  void setAPTo(int apNeu);
  int getAPNormal();
  int getAPCurrent();
  void reset();

  //Getter
  String get_id() => id;
  FACTION getFaction() => faction;
  List<EFFECTS> getEffects() => effects;
  List<ROWTYPE> getRowTypes() => rowTypes;
}