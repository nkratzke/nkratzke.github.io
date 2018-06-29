import 'dart:html';
import "Spielfigur.dart";
import "dart:math";
import "MainController.dart";
import "Wall.dart";
import "Bush.dart";
import "Skeleton.dart";
import "Potion.dart";
import "Hole.dart";

/**
 * Oberklasse aller Hindernisse, die im Level vorkommen, sowie des Hintergrunds
 */
abstract class Hindernis {
  //String-repräsentation der Typs
  String type;
  int xPos;
  //an den oberen Bildschirmrand setzen
  int yPos = MainController.height;

  Uri image;

  //Eigenschaften des Hindernisses
  bool destructable=false;

  bool shootable=false;

  bool jumpable=false;

  bool harmless=false;

  bool moving=false;

  //die Breite und Höhe der "Hitbox"
  //imageWidthPercentage beschreibt wie sehr das Objekt das eigentliche Bild ausfüllt,
  //so wird bei einem Wert von 50.0 das Bild doppelt so groß dargestellt.
  double actualWidth;
  double imageWidthPercentage;
  double actualHeight;
  //id des Objekts, die den HTML-Elementen mitgegeben wird, um diese einzeln ansprechen zu können
  static int objectId=0;
  int id;

  //gibt an, ob das Objekt noch bei der Kollisionsabfrage berücksichtigt werden muss
  bool hasCollided = false;

  //das Element, das dieses Hindernis repräsentiert
  Element selector;

  Hindernis(this.xPos,this.destructable,this.shootable,this.jumpable,this.harmless,this.moving) {
    id=objectId++;
  }

  int getX() => xPos;

  int getY() => yPos;


  Uri getImage() => image;

  void setImage(Uri image){
    this.image=image;
  }

  bool isDestructible() => destructable;


  bool isShootable() => shootable;


  bool isJumpable() => jumpable;


  bool isHarmless() => harmless;


  bool isMoving() => moving;


  /**
   * Überprüft, ob das Hindernis mit der übergebenen Spielfigur kollidiert
   */
  bool collidesWith(Spielfigur s){
    double distance;
    //Radius von Jones
    double r=s.width/2;
    //Unterschied in der x- und y-Position
    int xDif = (s.getXPos() - this.xPos).abs();
    int yDif = (this.yPos - s.yPos).abs();
    //Abbrechen, wenn es zu niedrig ist, da eine genaue Abfrage in dieser Hinsicht sich schlecht gespielt hat,
    //da man auf Hindernisse, die man augenscheinlich schon hinter sich gebracht hat, nicht achtet
    if((this.yPos+this.actualHeight/2)<s.yPos){
      return false;
    }
    //Berechne den Eigentlichen Abstand mit Rücksicht darauf, dass es sich um ein Viereck als Hindernis handelt
    if(xDif < this.actualWidth/2+s.width/2 && yDif < (s.height+this.actualHeight)/2){
      distance = (xDif*xDif +yDif*yDif) / 1.0;
      distance = sqrt(distance);
      if(distance < r + sqrt(pow(this.actualWidth/2, 2) + pow(this.actualHeight/2, 2)) ){
        return true;
      }
    }
    return false;
  }


  /**
   *  gibt eine Repräsentation des Objekts zurück, die von der factoryHindernis-Methode benutzt werden kann
   *  lässt sich fürs Erstellen von JSON-Dokumenten nutzen
   */
  List<String> toStringList() {

    List<String> list = new List<String>();
    list.add(type.toString());
    list.add(xPos.toString());

    return list;
  }

  /**
   * erstellt aus einer String-List-Repräsentierung eines Hindernisses ein Hindernis-
   * Objekt
   */
  static Hindernis factoryHindernis(List<String> list){
    switch(list[0]){
      case "wall":
        return new Wall(int.parse(list[1]));
      case "potion":
        return new Potion(int.parse(list[1]));
      case "skeleton":
        return new Skeleton(int.parse(list[1]));
      case "bush":
        return new Bush(int.parse(list[1]));
      case "hole":
        return new Hole(int.parse(list[1]));

    }
    return null;
  }

  /**
   * versteckt die HTML-Repräsentation dieses Objekts
   */
  removeImgFromHtml(List<Element> muellListe){
    this.selector.style.visibility = "hidden";
    muellListe.add(this.selector);
  }


}