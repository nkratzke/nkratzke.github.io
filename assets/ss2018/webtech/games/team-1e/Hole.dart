import "Hindernis.dart";
import 'Spielfigur.dart';

/**
 * Repräsentiert ein Loch im Boden
 */
class Hole extends Hindernis{


  Hole(int x)
      :super(x, false, true, false, false, false){
    image=new Uri.file("images/hole.png");
    imageWidthPercentage=90.0;
    actualWidth = 800.0;
    actualHeight=300.0;
    type="hole";
  }

  /**
   * überschreibt die Kollisionsabfrage der Hindernis-Klasse
   * mit Rücksicht auf den kleineren Bereich, in dem man erst Schaden erleidet
   */
  bool collidesWith(Spielfigur s){
        double width = actualWidth * 0.4;
        if(s.isJumping || s.isInvincible){
          return false;
        }
        if((xPos - s.xPos).floor() <width){
          if(yPos>s.yPos && yPos-s.yPos > actualHeight*0.6){
            return true;
          }
        }
        return false;

  }

}