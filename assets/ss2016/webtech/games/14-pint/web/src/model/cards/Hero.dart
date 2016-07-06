//part of pint;
import 'Unit.dart';
import '../static/Enum.dart';

/*implements functionality for hero-cards.
* this cards AP are immuteable by letting the setAPTo-method
* do nothing*/
class Hero extends Unit{

  Hero(id, name, level, fraktion, effekte, kannLiegen, apNormal, apAktuell) : super(id, name, level, fraktion, effekte,
      kannLiegen, apNormal, apAktuell);
  Hero.empty() : super.empty();

  /*overriding units method because hero cards shall not
  * be affected by any AP modifying effects*/
  @override
  void setAPTo(int apNeu){
  }

  /*returns a deep clone of this hero card*/
  Hero clone(){
    Hero reflux = new Hero.empty();
    reflux.id = new String.fromCharCodes(id.codeUnits);
    reflux.name = new String.fromCharCodes(name.codeUnits);
    reflux.level = level;
    reflux.faction = faction;
    reflux.effects = new List<EFFECTS>();
    effects.forEach((EFFECTS e)=>reflux.effects.add(e));
    reflux.rowTypes = new List<ROWTYPE>();
    rowTypes.forEach((ROWTYPE r)=>reflux.rowTypes.add(r));
    reflux.apNormal = apNormal;
    reflux.apCurrent = apNormal;
    reflux.tooltipText = tooltipText;
    reflux.tooltipDelay = tooltipDelay;
    return reflux;
  }
}