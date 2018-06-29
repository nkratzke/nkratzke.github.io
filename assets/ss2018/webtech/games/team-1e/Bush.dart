import "Hindernis.dart";

/**
 * Repräsentiert einen Busch oder eine Hecke
 */
class Bush extends Hindernis{


  Bush(int x)
    :super(x, true, false, false, false, false){
    image=new Uri.file("images/bush_by_publicdomainpictures_net.png");
    imageWidthPercentage=100.0;
    actualWidth = 800.0;
    actualHeight=150.0;
    type="bush";

  }
}