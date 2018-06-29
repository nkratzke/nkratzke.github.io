import "Hindernis.dart";


/**
 * realisiert einen Gesundheitstrank
 */
class Potion extends Hindernis{


  Potion(int x)
    :super(x,  false, false, false, true, false){
    image=new Uri.file("images/potion_small.png");
    imageWidthPercentage=100.0;
    actualWidth = 250.0;
    actualHeight=250.0;
    type="potion";
  }

}