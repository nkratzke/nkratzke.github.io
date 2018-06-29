import 'Spielfigur.dart';
import 'Hindernis.dart';
import 'MainController.dart';
import "Background.dart";
import "dart:math";
import "dart:convert";
import "Potion.dart";
import "dart:async";
import "dart:html";
import "package:resource/resource.dart";

class Model {
  //Die Liste aller Hindernisse, die sich zur Zeit auf dem Spielfeld befinden
  List<Hindernis> objectList = new List<Hindernis>();
  //Das ist unser Mexican Jones
  Spielfigur spielfigur = new Spielfigur(MainController.Halfwidth, false, false, false, false);
  //Eine Map, die alle Hindernisse, die noch kommen werden, sowie deren y-Wert, bei dem sie am oberen Rand auftauchen sollen, beinhaltet
  Map<String, List<Hindernis>> roadmap = new Map<String, List<Hindernis>>();
  //Wert, der angibt, ob das Level schon geladen wurde (da es ansonsten als beendet erkannt wird)
  bool loaded = false;
  //der Wert, wie weit sich Jones in Y-Richtung bewegt hat
  int yFortschritt = 0;


  /**
   *
   */
  MainController controller;
  Model(this.controller, String uri) {
    loadLevelFromJSON(uri);

  }


  /**
   * übersetzt das JSON-Dokument(bei richtiger Nutzung) in eine für das Model zu lesende roadMap
   */
  loadLevelFromJSON(String uri) async {
    Map <String, List<List<String>>> jsonMap = new Map <String,
        List<List<String>>>();
    //laden der Datei
    Uri u = new Uri.file(uri);
    var res = new Resource(u);
    String s;
    s = await res.readAsString();

    //Umsetzen in die jsonMap
    jsonMap = JSON.decode(s);
    //die jsonMap in die roadMap umwandeln
    loadLevelFromParseMap(jsonMap);
    loaded=true;
  }

  /**
   * Methode, die die übergebene Map in eine roadMap umwandelt und diese setzt
   */
  void loadLevelFromParseMap(Map<String, List<List<String>>> map) {
    //geht alle Elemente durch
    for (String s in map.keys) {
      //erzeuge die Spielfigur(und damit ihre Fähigkeiten)
      if (s == "spielfigur") {
        spielfigur = new Spielfigur(
            MainController.Halfwidth, map[s][0][0] == "true",
            map[s][0][1] == "true", map[s][0][2] == "true",
            map[s][0][3] == "true");
      }
      else {
        //erzeuge aus den List-Repräsentationen der Hindernisse echte Hindernisse
        List<Hindernis> list = new List<Hindernis>();
        for (List<String> hind in map[s]) {
          list.add(Hindernis.factoryHindernis(hind));
        }
        //füge alle Hindernisse, die bei diesem y-Wert angezeigt werden sollen, der roadmap hinzu
        roadmap[s] = list;
      }
    }

    }

  List<Hindernis> getObjectList() => objectList;


  /**
   * bewegt logisch Mexican Jones eine stepLength vorwärts
   * real werden alle Objekte um eine stepLength nach unten gesetzt
   */
  void step() {
    List<Hindernis> hindernissie = new List<Hindernis>();
    int key;

    //Überprüfe, ob bei diesem Step neue Objekte hinzugefügt werden müssen
    // gehe dabei auch davon aus, dass man keine Punktlandung auf dem y-Wert macht
    for (int i = MainController.stepLength; i >= 0; i--) {
      key = yFortschritt - i;
      if (roadmap.containsKey((yFortschritt - i).toString())) {

        hindernissie = roadmap.remove((key).toString());
        //Füge regelmäßig einen Background hinzu, der sich wie ein Hindernis ohne Kollisionen verhält
        //Workaround für das Problem, dass Hintergrund und Objekte sonst auf Smartphones asynchron waren
        if(key%3000 == 0){
          hindernissie.add(new Background(1500));
        }
        //füge die Objekte der ObjectList hinzu
        objectList.addAll(hindernissie);
        //und stelle diese dar
        hindernissie.forEach(controller.mainView.addToObjects);
      }
      else{

        //Backgrounds müssen auch hinzugefügt werden, wenn es keinen key gibt, der dort ein Hindernis platziert hätte
        if(key%3000 == 0){
          Background b = new Background(1500);
          objectList.add(b);
          controller.mainView.addToObjects(b);

        }
      }
    }
    //hochzählen
    yFortschritt += MainController.stepLength;
    //erkennt, ob das level beendet ist
    if (roadmap.isEmpty && loaded) {
      if(objectList.length==2 ){
        controller.nextLevel();
      }
    }
  }


  /**
   *   schiebt das Hindernis eine stepLength nach unten(logisch)
   */
  void processPutDown(Hindernis h) {
    h.yPos -= MainController.stepLength;
    //falls das Objekt aus dem Bildschirm verschwunden ist, entferne es aus der Liste
    if (h.yPos <= -300) {
      //eine sublist draus zu machen, hat sich als performanter herausgestellt, als .remove
      //dabei kam es jedesmal zu kleinen rucklern, wenn mehr als 2 Objekte gleichzeitig entfernt wurden
      objectList = objectList.sublist(1);
      //sorge auch dafür, dass das HTML-Element neu benutzt werden kann
      controller.mainView.freeImages.add(h.selector);
    }
  }


  /**
   * verarbeitet die Logik um einen Aufruf des ObjectDownMoverTimers
   * dabei werden alle Hindernisse nach unten gesetzt
   */
  void stepDown() {


    if(!objectList.isEmpty){
      objectList.forEach(processPutDown);
      }
  }


  /**
   * schiebt die Spielfigur abhängig von dem von den Bewegungstasten gesetzten Wert
   */
  void moveSpielfigur() {
    //erkennt, ob eine Bewegung nötig ist
    if (controller.playerMovementKey == 0||spielfigur.isJumping) {
      return;
    }
    //berechne die pro Aufruf des Timers nötige Bewegung
    int step = (MainController.speed /
        (1000 / MainController.intervall.inMilliseconds)).floor();
    step = controller.playerMovementKey < 0 ? -step : step;
    //Aktualisiere die Position, wenn damit die Spielfigur nicht außerhalb des Levels landet
    if (spielfigur.xPos + step <
        (MainController.Halfwidth * 2) &&
        spielfigur.xPos + step > 0) {
      this.spielfigur.xPos += step;
    }
  }

  /**
   * erkennt, ob eine Kollision mit der Spielfigur stattfindet
   */
  void detectCollision() {
    //wenn sie unverwundbar ist, brauch man nicht weiterzuschauen
    if(spielfigur.isInvincible){
      return;
    }
    Hindernis h;
    //schaue die ObjectList nacheinander durch
    for (int i = 0; i < objectList.length; i++) {
      h = objectList[i];
      //da die niedrigeren Hindernisse immer am Anfang der Liste stehen, kann man aufhören, zu überprüfen, ab einem bestimmten y-Wert
      if (h.yPos - spielfigur.yPos > (h.actualHeight + spielfigur.width) / 2) {
        break;
      }
      //die eigentliche Logik, ob die x- und y-Positionen eine Kollision verursachen, obliegt dem Hindernis
      if (!h.hasCollided && h.collidesWith(spielfigur)) {
        //wenn es verletztend ist
        if (!h.harmless) {
          spielfigur.hp--;

          spielfigur.isInvincible = true;
          new Timer(const Duration(seconds: 1), () => spielfigur.isInvincible = false);
          controller.mainView.blink(1000);
          controller.mainView.changeHP();
          h.hasCollided = true;
          if (spielfigur.hp <= 0) {
            controller.mainView.lost();
            controller.restart();
          }
          return;
        }
        //wenn es nicht verletztend ist ==> bei einem HP-Trank
        else {
          if (spielfigur.hp < 3) {
            spielfigur.hp++;
            controller.mainView.changeHP();
            h.hasCollided = true;
          }
          h.selector.style.visibility = "hidden";
        }
      }
    }
  }

  /**
   * Methode, die die Anpassung des x-Wertes, abhängig von der von der Lageerkennung gesetzten Variablen vornimmt
   */
  void tiltFigur() {
    //beim Springen soll keine Bewegung möglich sein
    if(spielfigur.isJumping){
      return;
    }
    bool pos;
    //Berechne die maximale Änderung
    int step = (MainController.speed /
        (1000 / MainController.intervall.inMilliseconds)).floor();
    double tilt = controller.playerMovementTilt * 1.0;
    if (tilt == 0) {
      return;
    }
    //Berechne den neuen Step(Änderung des x-Wertes)
    tilt = (tilt) / MainController.maxPhoneTilt;
    pos = tilt >= 0;
    tilt = tilt.abs();
    step = (step * tilt).floor();
    step = pos ? step : -step;
    if (spielfigur.xPos + step <
        (MainController.Halfwidth * 2) &&
        spielfigur.xPos + step > 0) {
      this.spielfigur.xPos += step;
    }
  }

  /**
   * führt einen Schlag der Machete aus
   */
  void chop() {
    if (spielfigur.hasMachete) {
      //sorge dafür, dass diese Fähigkeit nicht sofort wieder benutzt werden kann
      spielfigur.hasMachete=false;
      //durchsuche die ObjectList nach Objekten, die in Reichweite sind
      for (Hindernis h in objectList) {
        if (h.yPos > 750) {
          break;
        }
        //handelt es sich um einen Busch und dieser ist dicht genug, dann zerstöre ihn
        if (h.type == "bush" &&
            (spielfigur.xPos - h.xPos).abs() < (h.actualWidth / 2 + spielfigur.width /2)) {
          h.hasCollided = true;
          controller.mainView.destroy(h);
        }
      }
      //lasse den Controller den Timer starten, der dafür sorgt, dass chop wieder aufgerufen werden kann
      controller.timeChop();
    }
  }



  void stopJumping() {
    spielfigur.isJumping = false;
  }

  /**
   * lässt Jones einen Sprung ausführen
   */
  void jump() {
    if(!spielfigur.hasBoots){
      return;
    }
    //verhindere, dass diese Methode sofort wieder ausgeführt werden kann
    spielfigur.hasBoots = false;
    //setze den zugehörigen Wert
    spielfigur.isJumping = true;
    //sorge dafür, dass nach der Dauer eines Sprunges, diese Methode wieder ausgeführt werden kann
    new Timer(MainController.jumpDuration, () => spielfigur.hasBoots = true);
    //lasse den Controller den Wert von isJumping nach dem Sprung wieder auf false setzen
    controller.timeJump();
    //lasse die View den Sprung darstellen
    controller.mainView.jump();
  }

  /**
   * lässt Jones einen Unverwundbarkeitstrank trinken
   */
  void pot(){
    if(!spielfigur.isJuiceReady || spielfigur.isInvincible){
      return;
    }
    //setze die Datenfelder korrekt, so dass diese Methode nicht sofort wieder benutzt werden kann
    spielfigur.isJuiceReady = false;
    spielfigur.isInvincible = true;
    //die Dauer des Unverwundbarkeitseffektes
    new Timer(const Duration(milliseconds: 3000), ()=> spielfigur.isInvincible = false);
    //lasse ihn für die Dauer flimmern
    controller.mainView.blink(3000);
    //Abklingzeit
    new Timer(const Duration(seconds: 10), () => spielfigur.isJuiceReady = true);
  }

  /**
   * lässt Jones schießen
   */
  void shoot(){
    if(!spielfigur.hasGun){
      return;
    }
    //sorge dafür, dass es nicht sofort wieder ausgeführt werden kann
    spielfigur.hasGun =  false;
    controller.timeShot(); //Timer
    for(Hindernis h in objectList){
      if(h.type == "skeleton"){  //Skeletons können abgeschossen werden
        if((h.xPos - spielfigur.xPos).abs() < h.actualWidth/2 && !h.hasCollided && h.yPos > spielfigur.yPos ){ //wenn es noch nicht zerstört ist und sich über Jones befindet
          h.hasCollided = true;
          controller.mainView.destroy(h);   //verstecke das Objekt
          return;
        }
      }
    }
  }
}