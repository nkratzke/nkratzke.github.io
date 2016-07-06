import 'Card.dart';
import 'dart:html';
import '../static/Enum.dart';
import 'dart:async';

/*implements functionality for a playable card*/
class Unit extends Card{
  /*default ap of this unit card*/
  int apNormal,
  /*amount of ap this card currently got*/
      apCurrent,
  /*amount of horn effects triggered on this unit card*/
      hornCount;
  /*information wether this unit is a healer or not*/
  bool isPlayed;
  //Player besitzerOriginal, besitzerJetzt;

  Unit(id, name, level, fraktion, effekte, kannLiegen, this.apNormal, this.apCurrent)
      : super(id, name, level, fraktion, effekte, kannLiegen){
    level = 0;

  }
  Unit.empty() : super.empty();

  //****//
  //Misc//
  //****//
  /*Returns a deep-clone of this unit card*/
  Unit clone(){
    Unit reflux    = new Unit.empty();
    reflux.id         = new String.fromCharCodes(id.codeUnits);
    reflux.name       = new String.fromCharCodes(name.codeUnits);
    reflux.level      = level;
    reflux.faction    = faction;
    reflux.apNormal   = apNormal;
    reflux.apCurrent  = apNormal;
    reflux.effects    = new List<EFFECTS>();
    effects.forEach((EFFECTS e)=>reflux.effects.add(e));
    reflux.rowTypes = new List<ROWTYPE>();
    rowTypes.forEach((ROWTYPE r)=>reflux.rowTypes.add(r));
    reflux.tooltipText = tooltipText;
    reflux.tooltipDelay = tooltipDelay;
    return reflux;
  }

  /*Returns the name and the id of the unit*/
  String debugInfo(){
    return name + '/' + id  + '\n';
  }

  /*returns a basic html-element representing this card*/
  TableCellElement basicCellElement(){
    return _createDisplayElement(new TableCellElement());
  }
  /*returns a basic html-element representing this card*/
  DivElement basicDivElement(){
    return _createDisplayElement(new DivElement());
  }

  /*prepares a html element (preferably table cell or div) for
  * displaying a unit. adding tooltip-events if necessary and
  * clearing all active tooltips proactively on mouse down*/
  Element _createDisplayElement(Element e){
    e.classes.add('cardApElement');
    e.children.add(new DivElement());
    _addApAndCSS(e.children[0]);
    e.onMouseDown.listen((Event e) => _clearTooltip());
    if(effects.isNotEmpty){_addTooltipInfo(e);}
    return e;
  }

  /*only if card is no weather card ap are added as innerhtml*/
  void _addApAndCSS(Element e){
    if(effects.isEmpty || (effects.isNotEmpty && !(effects.contains(EFFECTS.WEATHER) || effects.contains(EFFECTS.GOODWEATHER))) ){
      e.innerHtml = getAPCurrent().toString();
    }
    _addApCssClass(e);
  }

  /*adds view-color for this units AP*/
  void _addApCssClass(Element e){
    if(effects.isNotEmpty){
      e.classes.add( effects[0] == EFFECTS.BROTHERHOOD ? 'cardNameTextEngebindung' :
      effects[0] == EFFECTS.HEALER ? 'cardNameTextHeiler' :
      effects[0] == EFFECTS.HORN ? 'cardNameTextHorn' :
      effects[0] == EFFECTS.MORALEBOOST ? 'cardNameTextMoralschub' :
      effects[0] == EFFECTS.SPY ? 'cardNameTextSpion' : 'cardNameTextDefault');
    }else{
      e.classes.add('cardNameTextDefault');
    }
  }

  /* adds events for the info-tooltip for a given HTML-element for both
   * mouse and touch displays*/
  void _addTooltipInfo(Element e){
    Timer t;
    e.onMouseDown.listen((Event ev){
      Element myInfo = document.getElementById('cardTooltip');
      print('MOUSEDOWN UNIT');
      t = new Timer(new Duration(milliseconds: tooltipDelay),(){
        myInfo.innerHtml = tooltipText;
        myInfo.classes.clear();
        myInfo.classes.add('cardInfoDiv');
        myInfo.style.top = e.offset.top.toString() + 'px';
        myInfo.style.left = e.offset.left.toString() + 'px';
        myInfo.style.zIndex = '666';
        myInfo.onClick.listen((Event e){
          _clearTooltip();
        });
      });
    });
    e.onMouseUp.listen((Event ev){
      print('MOUSEUP UNIT');
      t.cancel();
    });
  }

  /*clearing a tooltip for a card by erasing all css classes and adding
  * a new class with display:none*/
  _clearTooltip(){
    DivElement myInfo = document.getElementById('cardTooltip');
    myInfo.classes.clear();
    myInfo.classes.add('invis');
  }

  /*resetting card to default values*/
  void reset(){
    apCurrent = apNormal;
    //besitzerJetzt = besitzerOriginal;
    hornCount = 0;
  }

  /*Set current ap to a new value*/
  void setAPTo(int apNew){apCurrent = apNew;}

  int getAPNormal() {return apNormal;}
  int getAPCurrent(){return apCurrent;}
}