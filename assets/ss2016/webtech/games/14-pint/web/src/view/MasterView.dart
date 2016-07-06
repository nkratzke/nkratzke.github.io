import '../controller/MasterController.dart';
import 'dart:html';

class MasterView{
  //Klassenvariablen
  MasterController  controller;
  Element           view;
  TableElement      myTable;
  /*Die Input-Elemente werden von den Methoden im MasterController referenziert
  * sobald sie generiert werden. Anmelden und Offline Spielen brauchen das nicht,
  * da später nicht mehr auf sie zugegriffen werden muss.*/
  InputElement      ieUsername, iePassword;

  //Constructor
  MasterView(MasterController masterController){
    controller        = masterController;
    view              = querySelector('#masterView');
    myTable           = new TableElement();
    myTable.classes.add("logintable");
    view.classes.add("loginview");
  }

  /*This Method recreates the View*/
  update()async{
    myTable.children.clear();
    myTable.addRow().children.add(controller.ieUsername('Benutzername')..classes.add("benutzername"));
    if(controller.gamekeyAvailable){
      myTable.rows[0] .children.add(controller.iePassword('Passwort')..classes.add("passwort"));
      myTable.addRow().children.add(controller.beLogin('Anmelden')..classes.add("anmelden"));
      myTable.addRow().children.add(controller.beRegister('Registrieren')..classes.add("registrieren"));
    }else{
      myTable.addRow().children.add(controller.bePlayOffline('Offline spielen')..classes.add("offlineSpielen"));
    }

    view.children.clear();
    view.children.add(myTable);
  }

  /*This Method clears the View*/
  void clear(){
    view.children.clear();
  }
}