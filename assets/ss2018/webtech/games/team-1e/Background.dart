import 'Hindernis.dart';

/**
 * Diese Klasse realisiert den Hintergrund
 */
class Background extends Hindernis{

  /**
   * Unser Hintergrund wird auf 1500 gesetzt, aber wenn er nicht genau die Größe des Spielfelds hat
   * und man mehrere Elemente dafür benötigt, muss man diese an andere Stellen setzen
   */
  Background(int i)
    :super(i, false, false, false, false, false){
      this.hasCollided = true;
      this.image = new Uri.file("images/wallsie6.png");
      actualWidth=3200.0;
      actualHeight=6000.0;
      imageWidthPercentage=100.0;
      type = "Background";
      yPos = 3000;
  }




  }
