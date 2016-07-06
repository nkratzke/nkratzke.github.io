import 'dart:html';
import '../controller/AfterGameController.dart';
import '../model/cards/Card.dart';

class AfterGameView{

  //Class  variables
  AfterGameController controller;
  Element             view;
  TableElement        myTable;
  TableCellElement    result;
  TableRowElement     prize;

  //Constructor
  AfterGameView(AfterGameController agc){
    controller  = agc;
    view        = querySelector('#nachSpielView');
    myTable     = new TableElement();
    result      = new TableCellElement();
    prize       = new TableRowElement();
    result.classes.add("resultCell");
    myTable.classes.add("nachSpielViewTable");
  }

  /*This Method creates the AfterGame View*/
  void update(){
    view.classes.clear();
    view.classes.add('nachSpielViewElement');
    myTable.children.clear();
    controller.resultString();
    result.innerHtml = controller.calculateWinner();

    controller.wonCards.forEach((Card c) {
      TableCellElement cell = c.basicCellElement();
      prize.children.add(cell);
      cell.classes.add("nachSpielKarte");
      cell.classes.add("kartenid"+c.get_id());
    });

    TableRowElement tempRowElementRight;
    for(int i=0;i<2;i++) {//Add new Rows to Table and Row-Map
      tempRowElementRight = myTable.addRow();
      tempRowElementRight.classes.add("nachSpielViewRow");
    }

    myTable.rows[0].children.add(result);
    myTable.rows[1].children.add(controller.beNeustart());;
    myTable.children.add(prize);

    myTable.rows[1].children[0].classes.add("neustartButton");
    myTable.children[1].classes.add("nachSpielViewKartenRow");

    view.children.clear();
    view.children.add(myTable);
  }

  /*This Method clears the View*/
  void clear(){
    prize.children.clear();
    view.children.clear();
    view.classes.clear();
  }
}