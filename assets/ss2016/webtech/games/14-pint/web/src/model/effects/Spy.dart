import '../cards/Card.dart';
import 'dart:math';

/*implementing spys logic*/
class Spy{
  /*maximum amount of cards to be drawn by the spy*/
  int spyDrawMax;

  Spy(int spyDrawMax){
    this.spyDrawMax = spyDrawMax;
  }

  /*placing the spy in the fitting row of the opposite
  * players field and drawing two random cards from
  * the playing players deck card pile as long as the
  * pile holds enough cards*/
  void applyEffect(List<Card> hand, List<Card> deck){
    /*amount of cards already added to the players hand*/
    int    counter  = 0,
    /*maximum number of cards to be added to the players hand*/
           maxCards = spyDrawMax,
    /*index of next random card to be added from the deck
    * to the players hand*/
           nextRand = 0;
    /*provides random indizies for cards from the players deck*/
    Random rand     = new Random();

    print('spion effekt start');
    while(counter < maxCards){
      if(deck.length==0){
        print('spy: deck is empty! no cards to get');
      }
      else if(deck.length==1){
        hand.add(deck.removeLast());
      }
      else if(counter < maxCards){
        nextRand = rand.nextInt(deck.length);
        hand.add(deck.removeAt(nextRand));
      }
      counter++;
    }
  }
}