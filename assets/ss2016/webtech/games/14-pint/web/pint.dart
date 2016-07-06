import 'src/controller/FileLoader.dart';
import 'src/model/Game.dart';
import 'src/model/static/Settings.dart';
import 'src/controller/MasterController.dart';
import 'src/controller/GamekeyConnection.dart';
import 'src/model/static/Enum.dart';


 main() async{
   /*class used to load json files*/
   FileLoader fileLoader  = new FileLoader();
   /*holding all variables read from preferences.json*/
   Settings settings      = new Settings();
   settings.set(await fileLoader.getSettings());
   /*used for switching between the different game phases*/
   MasterController mc    = new MasterController(settings);
   /*representing the currents game state*/
   Game game             = new Game(mc);

   /*building the card pool used for cloning cards into players
   * or AIs card piles*/
   game.cardData.buildPool(await fileLoader.cards());
   /*connecting to the gamekey service*/
   GamekeyConnection gamekey = new GamekeyConnection(
      settings.get('gk_host'), settings.get('gk_port'), settings.get('gk_gameId'),
      'witcher2');

   /*setting reference to the gamekey service managing class*/
   mc.gamekey  = gamekey;
   /*setting the reference to the game state representing class*/
   mc.setGame(game);
   /*updating the games state to the login phase*/
   mc.update(GAMEPHASE.LOGIN, false);
}
