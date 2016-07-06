import '../controller/PreGameController.dart';
import 'dart:html';

class PreGameView{
  PreGameController controller;
  Element            view;
  TableElement       myTable;
  TableRowElement    reCardSelection, reDeck;

  //Constructor
  PreGameView(PreGameController preGameController){
    controller  = preGameController;
    view        = querySelector('#vorSpielView');
    myTable     = new TableElement();
    myTable.classes.add("vorSpielViewTable");
  }

  /*This Method creates the PreGame View*/
  void update(){
    print('vorSpielView update');
    controller.clearTceIDs();
    controller.clearDivIDs();
    view.classes.clear();
    view.classes.add('vorSpielViewElement');
    myTable.children.clear();

    for(int i=0;i<8;i++){
      myTable.addRow();
    }

    reCardSelection = myTable.rows[3];
    reCardSelection.classes.add("vorSpielViewRow");
    reDeck = myTable.rows[5];
    reDeck.classes.add("vorSpielViewRow");

    List<TableCellElement> kartenAuswahl = controller.tceCardsSelection();
    kartenAuswahl.forEach((TableCellElement t){
      t.classes.clear();
      t.classes.add("vorspielKarte");
      t.classes.add(controller.getCardClass("kartenid",t));
    });

    List<TableCellElement> kartenDeck = controller.tceCardsSelected();
    kartenDeck.forEach((TableCellElement t){
      t.classes.add("vorspielKarte");
      t.children.add(new DivElement()..classes.add("nestedTest"));
      t.classes.add(controller.getCardClass("kartenid",t));
    });


    myTable.rows[0].addCell()..innerHtml  = 'Spieler: ' + controller.getPlayerName() + ' '
        + 'Level:' + controller.getPlayer().level.toString()
        + ' Levelpunkte:' + controller.getPlayer().levelpoints.toString();
    myTable.rows[0].classes.add("spieler");
    myTable.rows[1].children.add(           controller.beFaction());
    myTable.rows[1].children[0].classes.add("factionButton");
    myTable.rows[2].innerHtml             = 'Kartenauswahl';
    myTable.rows[2].classes.add("kartenauswahl");
    reCardSelection.children.add(new DivElement()..classes.add("kartenStapelHook"));
    reCardSelection.children[0].children.addAll(        kartenAuswahl);
    myTable.rows[4].innerHtml             = 'Deck: '  + controller.getPlayer().getDeck().length.toString() + '/22';
    myTable.rows[4].classes.add("deck");
    reDeck.children.add(new DivElement()..classes.add("kartenStapelHook"));
    reDeck.children[0].children.addAll(        kartenDeck);
    myTable.rows[6].children.add(           controller.beDeleteDeck('Deck loeschen')..classes.add("deckloeschen"));
    myTable.rows[6].children.add(           controller.beHelp('Hilfe')..classes.add("hilfeButton"));
    myTable.rows[7].children.add(           controller.beStartGame('Spiel starten')..classes.add("spielstarten"));

    view.children.clear();
    view.children.add(myTable);
  }

  /*This Method clears the PreGame View*/
  void clear(){
    view.classes.clear();
    view.children.clear();
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
    TableRowElement backButtonContainer = reflux.addRow()..classes.add('helpTableButtonBackground');
    backButtonContainer.children.add(controller.beBack('Zurueck'));

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

    backButtonContainer.children[0].classes.add("backButton");

    return reflux;
  }

}