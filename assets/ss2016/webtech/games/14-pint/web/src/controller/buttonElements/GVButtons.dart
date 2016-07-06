import 'dart:html';
import '../GameController.dart';

/*provides html elements for the game view*/
class GVButtons{
  /*reference to the controller using this class for generating its
  * button elements including button logic*/
  GameController gc;

  GVButtons(GameController gameController){
    gc = gameController;
  }

  /*returns a button element enabling the player to fold a round.
  * setting players fold flag to true.
  * invokes a view and game controller update*/
  ButtonElement beFold(){
    ButtonElement reflux = new ButtonElement();
    reflux.innerHtml = 'Passen';
    reflux.onClick.listen((Event e){
      gc.getPlayer().hasFold = true;
      gc.view.update();
      gc.update(false);
    });
    return reflux;
  }

  /*generates a button element enabling the player to display the
  * help-table instead of the field.
  * removes itself from the view, adds the back-button and displays
  * the help-table*/
  ButtonElement beHelp([String s]){
    ButtonElement reflux = new ButtonElement();
    /*used for storing the field table while help table is displayed*/
    TableElement  buffer      = new TableElement(),
                  helpTable   = gc.view.helpTable(),
                  targetTable = gc.view.tableRight;
    /*row containing help or back button*/
    TableRowElement targetRow = gc.view.tableLeft.rows[10];

    reflux.innerHtml = s == null ? 'Hilfe' : s;
    reflux.onClick.listen((Event e){
      /*remove the help button*/
      targetRow.children.removeLast();
      /*save the view*/
      buffer.children.addAll(targetTable.children);
      /*and instead display the help table*/
      targetTable.children.addAll(helpTable.children);
      /*add back button instead*/
      targetRow.children.add(_beBack(buffer));
    });
    reflux.classes.add("helpButton");
    return reflux;
  }

  /*generates a button element enabling the player to close the
  * help table.
  * removes itself from the view and adds the help button back*/
  ButtonElement _beBack(TableElement buffer, [String s]){
    ButtonElement reflux = new ButtonElement();
    TableElement targetTable = gc.view.tableRight;
    TableRowElement targetRow = gc.view.tableLeft.rows[10];

    reflux.innerHtml = s == null ? 'Zurueck' : s;
    reflux.onClick.listen((Event e){
      /*remove the help table*/
      targetTable.children.clear();
      /*restore game view*/
      targetTable.children.addAll(buffer.children);
      /*remove the back button*/
      targetRow.children.removeLast();
      /*and add back the help button*/
      targetRow.children.add(beHelp());
    });
    reflux.classes.add("helpButton");
    return reflux;
  }

  /*displays player hands cards in the bottom row of the field
  * as playable elements*/
  ButtonElement bePlayerHand(){
    return _beDisplayRowUpdate(gc.divsPlayerHand(), true);
  }

  /*displays players discard cards in the bottow row of the field
  * as non-playable elements*/
  ButtonElement bePlayerDiscard(){
    return _beDisplayRowUpdate(gc.divPlayerDiscard(), false);
  }

  /*refreshes players card display by clearing its children and
  * adding whatever list of div elements is given.
  * boolean defines if hand or discard pile method has called*/
  ButtonElement _beDisplayRowUpdate(List<DivElement> source, bool hand){
    ButtonElement reflux = new ButtonElement();

    reflux.onClick.listen((Event e){
    TableCellElement targetCell = gc.view.cardDisplayRow.children[0];
      /*buffer for div elements to add position information to*/
      List<DivElement> divs = source;

      gc.playerCardDisplay().clear();
      if(hand){
        targetCell.innerHtml = 'Hand';
      }
      else{
        targetCell.innerHtml = 'Friedhof';
      }
      divs.forEach((DivElement div){
        div.classes.add("karte");
        div.classes.add(gc.getDivClass("kartenid", div));
      });
      gc.playerCardDisplay().addAll(
          gc.addPositionsForCardDivs(divs)
      );
    });
    return reflux;
  }
}