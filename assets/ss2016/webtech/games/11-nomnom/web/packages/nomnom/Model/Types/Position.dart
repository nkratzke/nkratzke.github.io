import 'dart:html';

class Position {
  int x;
  int y;
  int z;

  Position(this.x, this.y, [this.z]);

  int get X => x;

  int get Y => y;

  int get Z => z;

  set X(int value) => x = value;

  set Y(int value) => y = value;

  set Z(int value) => z = value;

  String toString(){
    return "pos_"+this.X.toString()+"_"+this.y.toString();
  }

  bool operator==(pos){
    return (pos is Position && (this.x==pos.x && this.y==pos.y));
  }

  int get hashCode {
    return (this.toString()).hashCode;
  }
}