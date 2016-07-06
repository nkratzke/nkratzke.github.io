import '../controller/GameController.dart';
import 'dart:html';
import '../model/static/Enum.dart';

class GameView{

  //Class  variables
  GameController                controller;
  Element                       view;
  TableElement                  tableLeft, tableRight;
  TableRowElement               tempRowElementLeft, cardDisplayRow;
  Map<String, TableRowElement>  rowsLeft, rowsRight;
  List<String>                  innerHtmlRight;
  String                        aiSiege   = ROWTYPEDIST.AISIEGE.toString(),
      aiDist  = ROWTYPEDIST.AIDIST.toString(),
      aiClose   = ROWTYPEDIST.AICLOSE.toString(),
      pSiege    = ROWTYPEDIST.PLAYERSIEGE.toString(),
      pDist   = ROWTYPEDIST.PLAYERDIST.toString(),
      pClose    = ROWTYPEDIST.PLAYERCLOSE.toString();

  //Constructor
  GameView(GameController gameController){
    /*Instantiate objects*/
    controller      = gameController;
    view            = querySelector('#spielView');
    tableLeft       = new TableElement();
    tableRight      = new TableElement();
    rowsLeft        = new Map<String, TableRowElement>();
    rowsRight       = new Map<String, TableRowElement>();
    innerHtmlRight  = new List<String>();

    innerHtmlRight.add(aiSiege);
    innerHtmlRight.add(aiDist);
    innerHtmlRight.add(aiClose);
    innerHtmlRight.add(pClose);
    innerHtmlRight.add(pDist);
    innerHtmlRight.add(pSiege);

    /*Add CSS-Classes to Tables*/
    tableRight.classes.add('spielViewTableRight');
    tableLeft.classes.add('spielViewTableLeft');
  }

  /*This Method creates the Game View*/
  void update(){
    print('spiel view update');
    view.classes.clear();
    view.classes.add('spielViewElement');
    controller.clearTceIDs();
    controller.clearDivIDs();
    tableLeft.children.clear();
    tableRight.children.clear();
    rowsLeft.clear();
    rowsRight.clear();

    /*left*/
    for(int i = 0;i<11;i++){
      tempRowElementLeft = tableLeft.addRow();
    }
    tableLeft.rows[0].addCell() ..innerHtml = 'Karten KI Friedhof: '  + controller.aiDiscardLength();
    tableLeft.rows[1].addCell() ..innerHtml = 'Karten KI Deck: '      + controller.aiDeckLength();
    tableLeft.rows[2].addCell() ..innerHtml = 'Karten KI Hand: '      + controller.aiHandLength();
    tableLeft.rows[3].addCell() ..innerHtml = 'KI gepasst: '          + controller.aiFold().toString();
    tableLeft.rows[4].addCell() ..innerHtml = 'KI Leben: '            + controller.getAILives() + '<br>KI AP: ' + controller.getAiAP().toString();
    tableLeft.rows[4].children[0].classes.add("borderKiSpieler");
    tableLeft.rows[5].addCell() ..innerHtml = ' AP: ' +controller.getPlayerAP().toString()  +   '<br>Leben: '    +controller.getPlayerLives();
    tableLeft.rows[6].addCell() ..innerHtml = 'Name: '     +controller.getPlayerName();
    tableLeft.rows[7].children.add(controller.bePlayerHand()
                                ..innerHtml = 'Hand: '     +controller.playerHandLength());
    tableLeft.rows[7].children[0].classes.add("handButton");
    tableLeft.rows[8].addCell() ..innerHtml = 'Deck: '     +controller.playerDeckLength();
    tableLeft.rows[9].children.add(controller.bePlayerDiscard()
                                ..innerHtml = 'Friedhof: ' +controller.playerDiscardLength());
    tableLeft.rows[9].children[0].classes.add("graveyardButton");
    tableLeft.rows[10].children.add(controller.beFold());
    tableLeft.rows[10].children.add(controller.beHelp('Help'));
    tableLeft.rows[10].children[0].classes.add("foldButton");
    tableLeft.rows[10].children[1].classes.add("helpButton");


    /*right*/
    TableRowElement tempRowElementRight;
    for(int i=0;i<6;i++){ //Add new Rows to Table and Row-Map
      tempRowElementRight = tableRight.addRow();
      if(i==0){
        tempRowElementRight.classes.add("spielfeldrow_belagerung");
      }
      if(i==1){
        tempRowElementRight.classes.add("spielfeldrow_fernkampf");
      }
      if(i==2){
        tempRowElementRight.classes.add("spielfeldrow_nahkampf");
      }
      if(i==3){
        tempRowElementRight.classes.add("spielfeldrow_nahkampf");
      }
      if(i==4){
        tempRowElementRight.classes.add("spielfeldrow_fernkampf");
      }
      if(i==5){
        tempRowElementRight.classes.add("spielfeldrow_belagerung");
      }
      tempRowElementRight.classes.add("spielfeldrow");
      TableCellElement tce = tempRowElementRight.addCell();
      tce.innerHtml = 'AP: 0';
      tce.classes.add('spielViewTableRight_AP');
      if(i==0){
        tce.classes.add("spielViewTableRight_AP_belagerung");
      }
      if(i==1){
        tce.classes.add("spielViewTableRight_AP_fernkampf");
      }
      if(i==2){
        tce.classes.add("spielViewTableRight_AP_nahkampf");
      }
      if(i==3){
        tce.classes.add("spielViewTableRight_AP_nahkampf");
      }
      if(i==4){
        tce.classes.add("spielViewTableRight_AP_fernkampf");
      }
      if(i==5){
        tce.classes.add("spielViewTableRight_AP_belagerung");
      }
      rowsRight.putIfAbsent(innerHtmlRight[i], ()=>tempRowElementRight);
    }
    cardDisplayRow = tableRight.addRow();

    /*Update CardDisplayElements for Player and KI*/
    /*Siege KI*/
    updateRowAISiege();
    /*Range KI*/
    updateRowAIDist();
    /*Melee KI*/
    updateRowAIClose();
    /*Siege Player*/
    updateRowPlayerSiege();
    /*Range Player*/
    updateRowPlayerDist();
    /*Melee Player*/
    updateRowPlayerClose();

    cardDisplayRow.children.clear();
    cardDisplayRow.classes.add("kartenAnzeige");

    cardDisplayRow.addCell().innerHtml = "Hand";
    cardDisplayRow.children.add(new DivElement());

    List<DivElement> handDivs = controller.divsPlayerHand();
    controller.addPositionsForCardDivs(handDivs).forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      cardDisplayRow.children[1].children.add(div);
    });

    view.children.clear();
    view.children.add(tableLeft);
    view.children.add(tableRight);
  }

  /*This Method clears the View*/
  void clear(){
    tableLeft.children.clear();
    tableRight.children.clear();
    rowsLeft.clear();
    rowsRight.clear();
    view.children.clear();
    view.classes.clear();
  }

  /*This Method updates the Siege Row from the Ki*/
  void updateRowAISiege(){
    rowsRight[aiSiege].children.add(new DivElement());
    controller.divAISiege().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[aiSiege].children[1].children.add(div);
    });
    rowsRight[aiSiege].children[0].innerHtml = controller.apAiSiege('AP: ');
  }

  /*This Method updates the Range Row from the Ki*/
  void updateRowAIDist(){
    rowsRight[aiDist].children.add(new DivElement());
    controller.divAIDist().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[aiDist].children[1].children.add(div);
    });
    rowsRight[aiDist].children[0].innerHtml = controller.apAiDist('AP: ');
  }

  /*This Method updates the Melee Row from the Ki*/
  void updateRowAIClose(){
    rowsRight[aiClose].children.add(new DivElement());
    controller.divAIClose().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[aiClose].children[1].children.add(div);
    });
    rowsRight[aiClose].children[0].innerHtml = controller.apAiClose('AP: ');
  }

  /*This Method updates the Siege Row from the Player*/
  void updateRowPlayerSiege(){
    rowsRight[pSiege].children.add(new DivElement());
    controller.divPlayerSiege().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[pSiege].children[1].children.add(div);
    });
    rowsRight[pSiege].children[0].innerHtml = controller.apPlayerSiege('AP: ');
  }

  /*This Method updates the Range Row from the Player*/
  void updateRowPlayerDist(){
    rowsRight[pDist].children.add(new DivElement());
    controller.divPlayerDist().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[pDist].children[1].children.add(div);
    });
    rowsRight[pDist].children[0].innerHtml = controller.apPlayerDist('AP: ');
  }

  /*This Method updates the Melee Row from the Player*/
  void updateRowPlayerClose(){
    rowsRight[pClose].children.add(new DivElement());
    controller.divPlayerClose().forEach((DivElement div){
      div.classes.clear();
      div.classes.add("karte");
      div.classes.add(controller.getDivClass("kartenid", div));
      rowsRight[pClose].children[1].children.add(div);
    });
    rowsRight[pClose].children[0].innerHtml = controller.apPlayerClose('AP: ');
  }

  /*This Method creates the Help-Page where all Card Abilities are explained*/
  TableElement helpTable(){
    TableElement reflux         = new TableElement();
    TableRowElement brotherhood = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement healer      = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement horn        = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement moraleBoost = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement spy         = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement weather     = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement goodWeather = reflux.addRow()..classes.add('helpTableColor');
    TableRowElement order       = reflux.addRow()..classes.add('helpTableColor');

    brotherhood.addCell();
    brotherhood.addCell();
    brotherhood.children[0].innerHtml = 'Enge Bindung';
    brotherhood.children[0].classes.add('helpTableColorBrotherhood');
    brotherhood.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.BROTHERHOOD');
    healer.addCell();
    healer.addCell();
    healer.children[0].innerHtml = 'Heiler';
    healer.children[0].classes.add('helpTableColorHealer');
    healer.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.HEALER');
    horn.addCell();
    horn.addCell();
    horn.children[0].innerHtml = 'Horn';
    horn.children[0].classes.add('helpTableColorHorn');
    horn.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.HORN');
    moraleBoost.addCell();
    moraleBoost.addCell();
    moraleBoost.children[0].innerHtml = 'Moralschub';
    moraleBoost.children[0].classes.add('helpTableColorMoraleBoost');
    moraleBoost.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.MORALEBOOST');
    spy.addCell();
    spy.addCell();
    spy.children[0].innerHtml = 'Spion';
    spy.children[0].classes.add('helpTableColorSpy');
    spy.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.SPY');
    weather.addCell();
    weather.addCell();
    weather.children[0].innerHtml = 'Schlechtes Wetter';
    weather.children[0].classes.add('helpTableColorWeather');
    weather.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.WEATHER');
    goodWeather.addCell();
    goodWeather.addCell();
    goodWeather.children[0].innerHtml = 'Sonne Gutes Wetter';
    goodWeather.children[0].classes.add('helpTableColorGoodWeather');
    goodWeather.children[1].innerHtml = controller.mc.settings.get('cardTooltipText_EFFECTS.GOODWEATHER');
    order.addCell();
    order.addCell();
    order.children[0].innerHtml = 'Berechnungsreihenfolge';
    order.children[1].innerHtml = controller.mc.settings.get('helpTableOrderOfApplication');

    return reflux;
  }
}