import 'Hindernis.dart';
import 'Spielfigur.dart';
import 'MainController.dart';
import 'dart:html';
import "dart:convert";
import "dart:async";

class MainView {

  //Zähler, der mitzählt, wieviele ticks von einem Sprung(Vergrößerungen von Jones) ausgeführt wurden
  static int counterJumper = 1;
  //der im Portrait-Mode angezeigte Text
  final Element message = querySelector("#msg");
  //das Elternelement, dem alle Hindernisse und der Background hinzugefügt werden
  final Element objects = querySelector('#objects');
  //Halbe Dauer eines Sprungs(Vergrößerungs- bzw. Verkleinerungszeit
  static const Duration jumpi = const Duration(milliseconds: 250);
  //der Anteil des Bildes, der zum Spielfeld gehört
  final double maxFramePercentage = 60.0;

  //hier werden benutzte, aber zur Zeit inaktive HTML-Elemente abgelegt, um sie wieder zu benutzen
  List<Element> freeImages = new List<Element>();

  MainController controller;

  //Timer für die Darstellung des Flickerns
  Timer t;

  //Variable, in der der Größenunterschied beim Sprung gespeichert wird
  double sizeChangeJump;

  //Variable, die speichert, wie oft Jones geflackert hat
  int ticks = 0;

  //das Bild, das einen Schuss darstellt
  Element gun = querySelector("#pew");
  //das Icon, das ein Schwert darstellt
  Element sword = querySelector("#sword");

  MainView(this.controller);

  //berechne YPos aus dem y-Wert
  double giveFrameYPos(int y) {
    double a = 100 / MainController.height;
    return y * a;
  }

  /**
   * berechne XPos aus dem x-Wert und dem Anteil des Spielfelds auf dem Bildschirm
   */
  double giveFrameXPos(int x) {
    double a = maxFramePercentage / (MainController.Halfwidth * 2);
    return x * a;
  }

  /**
   * aktualisiere die Position des Hindernisses
   */
  void showObject(Hindernis h) {
    h.selector.style.bottom = giveFrameYPos(h.yPos).toString() + "%";
  }


  /**
   * Erzeugt ein HTML-Element(oder entfernt eines aus der Liste an freien)
   * für das übergebene Hindernis und stellt dieses korrekt dar
   */
  void addToObjects(Hindernis h) {
    Element e;
    //die Größe des Objekts laut Model (mal hundert für die Berechnung später)
    double breite1=(100*h.actualWidth);
    //die Größe des Spielfelds laut Controller
    int breite2=(MainController.Halfwidth*2);
    //die Größe des Spielfelds auf dem Bildschirm
    double breite3=(h.imageWidthPercentage/100);
    if (freeImages.isEmpty) {
      e = new Element.img();
    } else {
      e = freeImages.removeAt(0);
    }
    e.style.visibility = "hidden";
    //gebe dem Element eine id, um es ansprechen zu können
    e.id = h.id.toString();
    //füge es zu den Objekten hinzu
    objects.children.add(e);
    h.selector = e;
    //zeige das Bild mit der richtigen Größe
    e.setAttribute("src", h.image.toString());
    e.style.width=((breite1/breite2)*(maxFramePercentage/100)
        /breite3)
        .toString()+"vw";
    //setze die Höhe des Objekts richtig
    e.style.height = ((h.actualHeight * 100) / MainController.height).toString()+"%";
    e.style.position = "fixed";
    //an den oberen Bildschirmrand
    e.style.bottom = "100%";
    //sorge dafür, dass der x-Wert des Objekts die Mitte  dessen anzeigt, schiebe es etwas nach oben, analog zu Jones, damit die Ansicht konsistent ist
    if(h.type=="Background"){
      e.style.transform = "Translate(-50%,  50%)";
      e.style.zIndex ="0";
    }
    else{
      e.style.transform = "translate(-50%, 50%)";
      e.style.zIndex= "2";
    }

    //setze es an den richtigen x-Wert
    e.style.left =
        ((100 - maxFramePercentage) / 2 + giveFrameXPos(h.xPos)).toString() +
            "%";

    //zeigen
    e.style.visibility = "visible";
  }

  /**
   *  fügt ein img-Element, das zu einem Hindernis zugehörig ist und fügt es zur Liste
   *  an freien Bildern hinzu
   *  -> wird später wieder benutzt, um nicht die ganze Zeit html-Elemente erzeugen zu müssen
   */
  void removeDom(Hindernis h) {
    h.selector.style.visibility = "hidden";
    freeImages.add(h.selector);
  }

  /**
   * "animiert" Jones' Schritte
   */
  void jonesSchritt() {
    //wechsele zwischen den Images, die Jones' Schrittabfolge darstellen
    controller.model.spielfigur.getImageFirst();
    querySelector('#jones').setAttribute(
        "src", controller.model.spielfigur.image.toString());
  }


  //Methode, die ehemals für die Darstellung einer Niederlage verantwortlich war
  void lost() {
    querySelector("body").style.backgroundColor = "darkred";
  }


  /**
   *   stellt den Inhalt des Bildes an die richtige Position, bzw gibt ihm die richtige Farbe, bei den Buttons
   */
  update() {
    //Berechne Position (sowie Neigung bei Geräteneigung) von Jones und stelle ihn entsprechend dar
    String left = ((100 - maxFramePercentage) / 2 +
        giveFrameXPos(controller.model.spielfigur.getXPos())).toString() + "%";
    querySelector('#output').style.left = left;
    querySelector('#jones').style.transform = "translate(-50%, 50%) rotate("+(controller.playerMovementTilt*2.5).toString()+"deg)";
    //Stellt alle Objekte, die in der objectList vorhanden sind, dar
    controller.model.objectList.forEach(showObject);
    //Abhängig vom Zustand des Spieles, zeige oder verstecke die Nachricht
    if(controller.running){
      hideMessage();
    }else{
      showMessage();
    }
    //aktualisiere die Buttons abhängig vom Zustand der Figur
    if(controller.model.spielfigur.hasMachete){
      querySelector("#topRight>img").style.opacity="1.0";
    }
    else{
      querySelector("#topRight>img").style.opacity="0.4";
    }
    if(controller.model.spielfigur.hasBoots){

      querySelector("#topLeft>img").style.opacity = controller.model.spielfigur.isJumping ? "0.2": "1.0";
    }
    else{
      querySelector("#topLeft>img").style.opacity="0.4";

    }
    if(controller.model.spielfigur.hasGun){
      querySelector("#bottomRight>img").style.opacity="1.0";
    }
    else{
      querySelector("#bottomRight>img").style.opacity="0.4";
    }
    if(controller.model.spielfigur.isJuiceReady){
      querySelector("#bottomLeft>img").style.opacity="1.0";
    }
    else{
      querySelector("#bottomLeft>img").style.opacity="0.4";

    }
  }

/*aktualisiert die HP-Anzeige, die oben links zu sehen ist
 */
  changeHP() {
    Element hp = querySelector("#health");
    int nmbrHP = controller.model.spielfigur.hp;
    while (hp.children.length != nmbrHP) {
      if (hp.children.length > nmbrHP) {
        if(nmbrHP <0 && hp.children.length == 0){
          break;
        }
        hp.children.removeLast();
      }
      else {
        Element img = new Element.img();
        img.setAttribute("src", "favicon.ico");
        hp.children.add(img);
        img.style.visibility = "visible";
        img.style.width="5vw";
      }
    }
  }
//Methode zum einmaligen Ausführen beim Start eines levels. Initialisiert die View
  init() {
    //packe das Schwert auf die richtige Höhe
    sword.style.bottom= "18%";

    //verstecke die icons fürs Schwert und die Pistole
    gun.style.visibility = "hidden";
    sword.style.visibility = "hidden";
    //lasse Jones eine Diät machen, damit er gut aufs Spielfeld passt
    querySelector("#jones").style.width =
        ((100 * controller.model.spielfigur.width) /
            (MainController.Halfwidth * 2) * 0.6).toString() + "vw";
    //und setze ihn an die richtige Stelle
    querySelector("#output").style.bottom =
        giveFrameYPos(controller.model.spielfigur.yPos).toString() + "%";
    querySelector('#output').style.left = ((100 - maxFramePercentage) / 2 +
        giveFrameXPos(controller.model.spielfigur.getXPos())).toString() + "%";

    //aktualisiere HP anzeige
    changeHP();

    querySelector("body").style.backgroundColor = "white";
    //setze den Background auf mittig
  }

  /** lässt Jones hüpfen
   *  funktioniert übers Größer-skalieren der Figur
   */
  jump(){
    //setze die von jumpJones benötigte Variable wieder auf 1
    counterJumper = 1;
    //berechne die Größenänderung
    double maxSize = ((100*controller.model.spielfigur.width)/
        (MainController.Halfwidth*2)*0.8);
    double currentSize = ((100*controller.model.spielfigur.width)/
        (MainController.Halfwidth*2)*0.6);
    sizeChangeJump = (maxSize-currentSize )/(250/20);
    //mache ihn größer
    jumpUp();
    //lass ihn nach 250 millisekunden wieder kleiner werden
    new Timer(const Duration(milliseconds:250), () => fallDown());
  }

  /**
   * initialisiert den Timer, um Jones' Größe hoch/runter zu skalieren und den, um diesen zu stoppen
   */
  jumpUp(){
    //lässt ihn hochspringen. jumpJones wird der Multiplikator übergeben, mit dem die Größenänderung verrechnet wird
    Timer jumper = new Timer.periodic(const Duration(milliseconds: 20),(jumper) => jumpJones(1));
    new Timer(jumpi, () => jumper.cancel());
  }

  /**
   * führt die eigentliche Größenänderung durch
   * in unserem Fall wird i lediglich 1 oder -1 sein
   */
  jumpJones(int i ){
    Element jones = querySelector("#jones");
    jones.style.width = (((100*controller.model.spielfigur.width)/
        (MainController.Halfwidth*2)*0.6) + i.abs()*sizeChangeJump*counterJumper ).toString()+"vw";
    counterJumper+= i;

  }

  /**
   * funktioniert analog zu jumpUp, lediglich wird Jones hier kleiner gemacht
   */
  fallDown(){
    Timer faller = new Timer.periodic(const Duration(milliseconds: 20), (faller) => jumpJones(-1));
    new Timer(jumpi, () => faller.cancel());
  }

  /**
   * lässt Jones einen Schlag ausführen
   */
  void showSlash(){
    //berechne Position des Icons
    double left = (((100 - maxFramePercentage) / 2 +
        giveFrameXPos(controller.model.spielfigur.getXPos()))-1);
    //stelle es korrekt da
    sword.style.transform = "translate(-50%, 50%) rotate(-90deg)";
    sword.style.left = (left-0.2).toString()+"%";
    sword.style.visibility = "visible";
    //erzeuge Timer, um das Schwert zu bewegen und es wieder zu verstecken
    new Timer(const Duration(milliseconds: 100),()=> sword.style.visibility = "hidden");
    new Timer(const Duration(milliseconds: 50), ()=> slashie(((100 - maxFramePercentage) / 2 +
        giveFrameXPos(controller.model.spielfigur.getXPos())+1.5)));
  }

  /**
   * stellt das etwas gedrehte Schwert-Icon dar
   */
  void slashie(double d){
    sword.style.left = (d).toString()+"%";
    sword.style.transform = "translate(-50%, 50%) rotate(-50deg)";
  }

  /**
   * lässt Jones einen Schuss ausführen
   */
  void showPew() {
    //berechne Position (+0.5 -> die Breite des Dreiecks)
    String left = ((100 - maxFramePercentage) / 2 +
        giveFrameXPos(controller.model.spielfigur.getXPos())+0.5).toString() + "%";
    //stelle es dar
    gun.style.left = left;
    gun.style.bottom = "14.5%";
    gun.style.visibility = "visible";
    //verstecke das Icon wieder
    new Timer(const Duration(milliseconds: 50), () =>gun.style.visibility = "hidden");
  }

  /**
   * lässt Jones für millis Millisekunden flackern, in einer Periode von 200ms
   */
  void blink(int millis){
    ticks = 0;
    t = new Timer.periodic(const Duration(milliseconds: 100),(t)=> blinkingJones(millis) );
  }

  /**
   * übernimmt die eigentlichen DOM-Änderung für die blink-Methode
   */
  blinkingJones(int millis){
    //zähle ticks weiter
    ticks ++;
    Element jon = querySelector("#output");
    //Ändere die Sichtbarkeit
    if(jon.style.visibility =="visible"){
      jon.style.visibility = "hidden";
    }
    else{
      jon.style.visibility = "visible";
    }
    //wenn der Zeitraum überschritten ist, stopp
    if(100 * ticks > millis){
      jon.style.visibility = "visible";
      t.cancel();
    }
  }

  void showCredits(){
    querySelector("#creditLink").style.visibility = "hidden";
    querySelector("#backLink").style.visibility ="visible";
    querySelector("#credits").style.visibility="visible";
  }

  void hideCredits(){
    querySelector("#creditLink").style.visibility = "visible";
    querySelector("#backLink").style.visibility ="hidden";
    querySelector("#credits").style.visibility="hidden";
  }

  /**
   * versteckt die Anzeige des Portrait-Mode Textes
   */
  void hideMessage(){
    message.style.visibility = "hidden";
  }

  /**
   * zeigt den Portrait-Mode Text
   */
  void showMessage(){
    message.style.visibility = "visible";
  }

  /**
   * verstecke das HTML-Element, das zu dem übergebenen Hindernis gehört
   */
  void destroy(Hindernis h){
    h.selector.style.visibility="hidden";
  }

}