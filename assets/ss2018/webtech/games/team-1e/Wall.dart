import 'Hindernis.dart';

/**
 * realisiert eine Wand
 */
class Wall extends Hindernis{


  Wall(int xPos)
      :super (xPos,false,false,false,false,false){
    image = new Uri.file("images/1075.png");
    imageWidthPercentage=100.0;
    actualWidth = 800.0;
    actualHeight=150.0;
    type="wall";
  }
}