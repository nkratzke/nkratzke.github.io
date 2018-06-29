import 'dart:async';
import 'Model.dart';
import 'MainView.dart';
import 'dart:html';
import "Fall.dart";
import "dart:math";
import "dart:convert";

/**
 * Objekt, das als Verbindung zwischen Model und View agiert und für die Steuerung des Programmablaufs zuständig ist
 */
class MainController {
  //gibt an, ob das Programm derzeit läuft
  bool running = true;
  //gibt an, ob der Hintergrund geladen wurde
  bool ready = false;
  //Jones'Geschwindigkeit in x-Werten pro Sekunde
  static const int speed = 2500 ;
  //Höhe des Spielfelds, sollte ein gerader Wert sein
  static const int height=3000;
  //Halbe Breite des Spielfelds (da eine Halbierung oft nötig ist)
  static const int Halfwidth=1500;

  //Die Anzahl, der beim nächsten Aufruf des roadMapperTimers gewarteten Millisekunden und damit, der zu verarbeitende YFortschritt
  static const stepLength = 16;
  //das Intervall, nach welchem Jones' Position aktualisiert wird
  static const Duration intervall = const Duration(milliseconds: 12);
  //das Intervall, nach welchem die Positionen der Hindernisse, sowie des Hintergrunds, aktualisiert werden
  static const Duration updateIntervall = const Duration(milliseconds: 12);
  //das Intervall, nach welchem Jones einen Schritt ausführen soll
  static const Duration jonesIntervall = const Duration(milliseconds:300);
  //das Intervall, nach welchem weitere Objekte aus der Roadmap zur ObjektList hinzugefügt werden sollen(falls vorhanden)
  static const Duration roadmapperIntervall = const Duration(milliseconds: stepLength);
  //das Intervall, nach welchem Objekte logisch bewegt werden
  static const Duration objectDownmoverIntervall = const Duration(milliseconds: stepLength);
  //das Intervall, nach welchem eine Kollisionsabfrage mit Jones stattfindet
  static const Duration collisionIntervall = const Duration(milliseconds: 8);
  //das Intervall, das angibt, wielang ein Sprung dauert
  static const Duration jumpDuration = const Duration(milliseconds: 500);
  //das Intervall, das angibt, wielang eine Fähigkeit nach Benutzung nicht mehr verwendet werden kann (Schwert und Shotgun)
  static const Duration abilityCoolDown = const Duration(milliseconds: 300);
  Model model;
  MainView mainView;

  //die durch Tastendruck ausgelöste Bewegung
  int playerMovementKey = 0;
  //die durch Lageänderung des Geräts ausgelöste Bewegung
  //ein höherer Wert bedeutet höhere Geschwindigkeit
  int playerMovementTilt = 0;
  //Variable zur weiteren Berechnung der Geschwindigkeit
  int dummyMov= 0;
  //Timer, die den Programmablauf realisieren:
  //Bewegung von Jones
  Timer moveTimer;
  //Darstellen der Objekte
  Timer updatePositionTimer;
  //Laufenlassen von Jones
  Timer showJonesTimer;
  //Objekte von der Roadmap in die ObjectMap packen
  Timer roadmapperTimer;
  //Objekte runter bewegen
  Timer objectDownmoverTimer;
  //Kollisionen erkennen
  Timer collisionTimer;
  //Geräteneigung erkennen und den Wert von playerMovementTilt anpassen
  Timer tiltTimer;

  //es wird davon ausgegangen, dass der relative Pfad zum level dem Schema "levelString"+aktuellesLevel+".json" folgt
  String levelString = "level/level";
  //das aktuell zu startende Level
  int aktuellesLevel = 1;
  //Liste, die alle Timer enthält, um diese einfach starten und schließen zu können
  List<Timer> timers = new List<Timer>();
  //bools, um zu überprüfen ob die Tasten für die Bewegung schon gedrückt wurden. Haben keinen Einfluss auf mobile
  bool trL = false;
  bool trR = false;
  //die maximale Anzahl an Leveln, die gespielt werden kann
  final int levelCount=7;
  //Enums für die Bildschirmausrichtungen. Für Lesbarkeit
  static const Fall ZWEI = Fall.rechtsVorne;
  static const Fall EINS = Fall.rechtsHinten;
  static const Fall VIER =Fall.linksVorne;
  static const Fall DREI = Fall.linksHinten;


  //Konstante, die angibt, bei welchem Neigungsgrad die maximale Bewegungsgeschwindigkeit erreicht wird
  static const maxPhoneTilt = 20;


  /**
   * lädt das nächste Level, falls vorhanden
   */
  void nextLevel(){

    if(aktuellesLevel>levelCount){
      return;
    }
    String str = levelString+aktuellesLevel.toString()+".json";
    model = new Model(this, str);
    mainView.init();

    aktuellesLevel++;
  }

  /**
   * startes das aktuelle Level erneut
   */
  void restart(){
    if(aktuellesLevel>1)aktuellesLevel--;
    //entferne die noch vorhandenen HTML-Elemente der Hindernisee von der View
    model.objectList.forEach((h) => h.removeImgFromHtml(mainView.freeImages));
    model = new Model(this, levelString+aktuellesLevel.toString()+".json");
    mainView.init();
    aktuellesLevel++;
  }

  /**
   * startet das Spiel, sowie alle Timer
   */
  void launch() {

    model=new Model(this,levelString+aktuellesLevel.toString()+".json");
    aktuellesLevel++;
    mainView=new MainView(this);
    mainView.init();

    //dieser Timer hat allein keine Auswirkungen und kann daher schon losgehen
    updatePositionTimer = new Timer.periodic(updateIntervall, (Timer updatePositionTimer)=>mainView.update());


    //warte darauf, dass der Hintergrund geladen wird, bevor es losgeht
    ImageElement img = new ImageElement();
    img.src = "images/wallsie6.png";
    img.onLoad.first.then((e)=> startLevel());

    //setze keyListener für die Steuerung am Desktop
    window.onKeyDown.listen((KeyboardEvent e) {

      if(e.keyCode==49){
        model.jump();
        return;
      }
      if(e.keyCode==50){
        model.chop();
        return;
      }
      if(e.keyCode==51){
        model.pot();
        return;
      }
      if(e.keyCode==52){
        model.shoot();
        return;
      }
      //hier wird darauf geachtet, dass das gleichzeitige Drücken der unterschiedlichen Bewegungstasten nicht
      //zu ungewollten Effekten führt
      if (e.keyCode == 37 && !trL) {
        playerMovementKey = playerMovementKey == 0 ? -speed : 0;
        trL = true;
        if(moveTimer == null){
          moveTimer = new Timer.periodic(intervall, (Timer moveTimer)=>model.moveSpielfigur());
        }
      }
      if (e.keyCode == 39 && !trR) {
        playerMovementKey = playerMovementKey == 0 ? speed : 0;
        trR = true;
        if(moveTimer == null){
          moveTimer = new Timer.periodic(intervall, (Timer moveTimer)=>model.moveSpielfigur());
        }
      }

    });
    //das Loslassen der Tasten wird so behandelt, dass falls die andere Bewegungstaste noch gedrückt ist,
    //diese ihr gewohntes Verhalten zeigt
    window.onKeyUp.listen((KeyboardEvent e) {
      //mit der Taste R lässt sich das Level neustarten
      if(e.keyCode == 82){
        this.restart();
        return;
      }
      if (e.keyCode == 37) {
        playerMovementKey += speed;
        trL=false;
        if(trR == false){
          moveTimer.cancel();
          moveTimer = null;
        }
      }
      if (e.keyCode == 39) {
        playerMovementKey -= speed;
        trR=false;
        if(trL == false){
          moveTimer.cancel();
          moveTimer = null;
        }
      }
    });


    /**
     * Listener für die Lageerkennung
     */
    window.onDeviceOrientation.listen((DeviceOrientationEvent e){
      //falls sich das Gerät im Portrait-Mode befindet, pausieren
      if(window != null && window.orientation.abs() != 90){
        if(running){
          pause();
          running = false;
        }
        return;
      }
      else{
        //falls es sich nicht im Portrait-Mode befindet, und das Bild geladen ist, starten
        if(!running && ready){
          running = true;
          startTimers();
        }
      }
      //falls es sich bei dem Gerät um ein Lagefähiges Gerät handelt
      if(e.beta != null) {
        int mult;
        // runde den Wert ab, merke dabei, ob er vorher positiv oder negativ war
        mult = e.beta < 0 ? -1 : 1;
        int beta = e.beta.abs().floor() * mult;
        mult = e.gamma < 0 ? -1 : 1;
        int gamma = e.gamma.abs().floor() * mult;
        var Fall;
        //falls die Neigung zu niedrig ist, findet keine Bewegung statt
        if(beta.abs()<3 || beta.abs() > 177){
          playerMovementTilt = 0;
          return;
        }
        //erkenne welcher Fall der Bildschirmausrichtung greift
        if (beta.abs() < 90) {
          if (gamma >= 0 ) {
            Fall = EINS;
          } else {
            Fall = DREI;
          }
        } else {
          if (gamma < 0 ) {
            Fall = ZWEI;
          }
          else {
            Fall = VIER;
          }
        }
        mult = 0;


        //behandle die jeweiligen Fälle
        switch(Fall) {
          case EINS:
            mult = beta > 0 ? -1 : 1;
            //Multiplikator, abhängig davon, wie dicht der Winkel von Gamma an 20 Grad ist
            int tilt = (e.beta.abs()  * (e.gamma.abs() < 40 ? 1+ min(((40 - e.gamma.abs())/20 ), 2.5 ) : 1  )).floor();
            tilt = min(maxPhoneTilt, tilt);
            mult = tilt*mult;

            break;
          case ZWEI:
            mult = beta > 0 ? -1 : 1;
            int tilt = (180-e.beta.abs() * (e.gamma.abs() < 40 ? 1+min(((40 - e.gamma.abs())/20 ), 2.5 ): 1  )).floor();
            tilt = min(maxPhoneTilt, tilt);
            mult = tilt*mult;
            break;
          case DREI:
            mult = beta > 0 ? 1 : -1;
            int tilt = (e.beta.abs() * (e.gamma.abs() < 40 ? 1+min(((40 - e.gamma.abs())/20 ), 2.5 ): 1  )).floor();
            tilt = min(maxPhoneTilt, tilt);
            mult = tilt*mult;
            break ;
          case VIER:
            mult = beta > 0 ? 1 : -1;
            int tilt = (180-e.beta.abs() * (e.gamma.abs() < 40 ? 1+min(((40 - e.gamma.abs())/20 ), 2.5 ) : 1  )).floor();
            tilt = min(maxPhoneTilt, tilt);
            mult = tilt*mult;
            break;
        }
        playerMovementTilt = mult;
      }



    });
    //gebe den Buttons ihr verhalten
    querySelector('#topRight').onTouchEnd.listen((TouchEvent e){
      model.chop();
    });
    querySelector('#topRight').onMouseUp.listen((MouseEvent e){
      model.chop();
    });
    querySelector('#topLeft').onTouchEnd.listen((TouchEvent e){
      model.jump();

    });
    querySelector('#topLeft').onMouseUp.listen((MouseEvent e){
      model.jump();
    });

    querySelector("#bottomRight").onMouseUp.listen((MouseEvent e){
      model.shoot();
    });

    querySelector("#bottomRight").onTouchEnd.listen((TouchEvent e){
      model.shoot();
    });

    querySelector("#bottomLeft").onMouseUp.listen((MouseEvent e){
      model.pot();
    });

    querySelector("#bottomLeft").onTouchEnd.listen((TouchEvent e){
      model.pot();
    });

    querySelector("#restart").onMouseUp.listen((MouseEvent e){
      this.restart();
    });

    querySelector("#restart").onTouchEnd.listen((TouchEvent e){
      this.restart();
    });

    querySelector("#creditLink").onTouchEnd.listen((TouchEvent e){
      mainView.showCredits();
    });
    querySelector("#creditLink").onMouseUp.listen((MouseEvent e){
      mainView.showCredits();
    });

    querySelector("#backLink").onTouchEnd.listen((TouchEvent e){
      mainView.hideCredits();
    });
    querySelector("#backLink").onMouseUp.listen((MouseEvent e){
      mainView.hideCredits();
    });



  }


  /**
   *
   * lässt die Timer losgehen
   */
  void startLevel(){
    ready=true;
    startTimers();
  }

  /**
   * die Pause-Methode, wie sie benutzt wird, wenn der Portrait-Modus erkannt wird
    */
  void pause(){
    for(Timer t in timers){
      if(t!=null){
        t.cancel();
      }
    }
  }

  /**
   * lässt alle Timer losgehen, die unser Spiel realisieren
   */
  void startTimers(){
    roadmapperTimer = new Timer.periodic(roadmapperIntervall, (Timer roadmapperTimer)=>model.step());
    collisionTimer = new Timer.periodic(collisionIntervall, (Timer collisionTimer) => model.detectCollision());
    tiltTimer = new Timer.periodic(intervall, (Timer tiltTimer) => model.tiltFigur());
    showJonesTimer = new Timer.periodic(jonesIntervall, (Timer showJonesTimer)=>mainView.jonesSchritt());
    objectDownmoverTimer= new Timer.periodic(objectDownmoverIntervall, (Timer objectDownmoverTimer)=>model.stepDown());


    timers.add(roadmapperTimer);
    timers.add(collisionTimer);
    timers.add(tiltTimer);
    timers.add(showJonesTimer);
    timers.add(objectDownmoverTimer);

  }


  /**
   * setzt nach der Dauer eines Sprunges den isJumping-Wert von der Spielfigur auf false
   */
  timeJump(){
    new Timer(jumpDuration, () => model.spielfigur.isJumping = false);
  }

  /**
   * lässt nach der Dauer einer Abklingzeit die Figur wieder eine Machete haben
   */
  timeChop(){
    mainView.showSlash();
    new Timer( abilityCoolDown, () => model.spielfigur.hasMachete = true);
  }

  /**
   * lässt nach der Dauer einer Abklingzeit die Figur wieder eine Kanone haben
   */
  timeShot(){
    mainView.showPew();
    new Timer( abilityCoolDown, () => model.spielfigur.hasGun= true);
  }

}