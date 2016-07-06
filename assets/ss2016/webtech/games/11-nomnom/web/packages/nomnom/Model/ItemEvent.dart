import 'GameTable.dart';
import 'GameObject.dart';

class Event{
  int tick = 0;
  int type;
  int tickMax;
  GameTable myTable;

  Event(this.myTable, this.type){
    this.tickMax = this.myTable.parameters["EventTicks"];
  }

  void onTick(){
    tick++;
    if(tick >= tickMax){
      switch(type){
        case GameObject.raspberry:
          myTable.removeEvent(1,this);
          break;
        case GameObject.lemon:
          myTable.removeEvent(1,this);
          break;
        case GameObject.blueBonbon:
          myTable.removeEvent(2,this);
          break;
        case GameObject.redBonbon:
          myTable.removeEvent(2,this);
          break;
        case GameObject.greenBonbon:
          myTable.removeEvent(3,this);
      }
    }
  }
}
