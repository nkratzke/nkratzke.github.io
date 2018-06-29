import "dart:html";

/**
 * die Spielfigur, die Jones' Eigenschaften beschreibt
 */
class Spielfigur {
  //Anzahl an Treffern, nach denen das Spiel vorbei ist
  int hp = 3;
  //das aktuell anzuzeigende Bild von Jones
  Uri image;
  //die Bilder, zwischen denen gewechselt wird
  List<Uri> gif = [new Uri.file("images/jones_1.png"),new Uri.file("images/jones_2.png")];
  //die momentane Position, an der sich Jones befindet
  int xPos;
  //die Höhe, an der er läuft
  final int yPos = 150;
  //seine Breite und Höhe
  int width=250;
  int height=250;


  //seine Eigenschaften
  bool isInvincible =false;
  bool isJuiceReady;
  bool hasMachete;
  bool hasBoots;
  bool hasGun;
  bool isJumping = false;
  Spielfigur(this.xPos,this.isJuiceReady, this.hasMachete, this.hasBoots, this.hasGun) {
    getImageFirst();
  }

  /**
   * methode, die das anzuzeigende Bild austauscht
   */
  void getImageLast(){
    gif.add(gif.removeLast());
    image = gif.last;
  }
  /**
   * methode, die das anzuzeigende Bild austauscht
   */
  void getImageFirst() {
    gif.add(gif[0]);
    image=gif.removeAt(0);
    }

  getXPos() => xPos;

  void setXPos(int x){
    this.xPos += x;
  }

  bool giveInvinciblity() => isInvincible;

  bool giveJuiceReadyNess() => isJuiceReady;

  bool giveMachetebility() => hasMachete;

  bool giveBootability() => hasBoots;

  bool giveGunnability() => hasGun;

}