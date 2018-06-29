import "Hindernis.dart";

/**
 * realisiert einen Gegner
 */
class Skeleton extends Hindernis {


  Skeleton(int x)
      :super(x, true, false, false, false, true) {
    image = new Uri.file("images/skeleton_by_wikimedia_org.png");
    imageWidthPercentage=100.0;
    actualWidth = 450.0;
    actualHeight=600.0;
    type="skeleton";
  }
}