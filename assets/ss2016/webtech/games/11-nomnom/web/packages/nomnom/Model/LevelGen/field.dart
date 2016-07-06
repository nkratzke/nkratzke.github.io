import '../GameObject.dart';

/**
 * Field data storage
 */
class Field{
  num dimX;
  num dimY;
  int freeFields = 0;

  List<List<num>> field;

  Field(this.dimX, this.dimY){
    this.field = new List.generate(dimY, (i) => new List.filled(dimX,GameObject.block));
  }

  void setField(num i, num j, num val){

    if( val == GameObject.empty && this.field[i%dimX][j%dimY] != val)
      freeFields++;

    this.field[i%dimX][j%dimY] = val;
  }

  void setFieldSym(int i, int j, int val){
    setField(i%dimX,j%dimY,val);
    setField((((dimX-1)-i)%dimX).floor(),j%dimY,val);
    setField(i%dimX,(((dimY-1)-j)%dimY).floor(),val);
    setField((((dimX-1)-i)%dimX).floor(),(((dimY-1)-j)%dimY).floor(),val);
  }

  int getNeighbouts(int i, int j){
    return  this.field[(i-1)%dimX][j] + this.field[(i+1)%dimX][j]
        + this.field[i][(j-1)%dimY] + this.field[i][(j+1)%dimY]  ;
  }

  String toString(){
    String ret ="";
    for(List row in this.field){
      for(var col in row){
        ret += (col==GameObject.block?"#":" ");
      }
      ret += "\n";
    }
    return ret;
  }


  getField(int x, int y) {
    return field[x%dimX][y%dimY];
  }
}