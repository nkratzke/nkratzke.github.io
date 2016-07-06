import '../lib/Controller/Controller.dart';
import '../lib/GameKey/GameKey.dart';
import '../lib/Debug.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'DataLoader.dart';

String gameSecret;//="324e9f924bd442e8";
String gameID;//="a7c58f11-6245-470c-b363-fae38a5ca31b";
GameKey gamekey;
Controller con;
DataLoader loader;


/**
 * Starter class for NomNom game
 */
class Starter{

  /**
   * Constructor
   */
  Starter(){
    loader = new DataLoader(this);
    loader.loadData();
  }

  /**
   * Start the game
   */
  void startGame(){

    int port = loader.gamekeyData["port"];
    String host = loader.gamekeyData["host"];
    gameID = loader.gamekeyData["id"];
    gameSecret = loader.gamekeyData["secret"];
    final bt_register = querySelector("#registerButton");
    final bt_login = querySelector("#loginButton");
    final bt_offline = querySelector("#offlineButton");
    final bt_highscore = querySelector("#highscoreButton");

    // Offline button mouse event
    bt_offline.onClick.listen((Event mw){
      gamekey = new GameKey("", 0, gameID, gameSecret);
      gamekey.offline = true;
      querySelector("#welcome").innerHtml ="<input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
      querySelector("#score").innerHtml="Score:";
      con = new Controller(gamekey, true, loader.mapData, loader.parameters);
    });

    // Highscore button mouse event
    bt_highscore.onClick.listen((e) async{
      gamekey = new GameKey(host, port, gameID, gameSecret);//new GameKey("212.201.22.161", 50001, gameID, gameSecret);
      gamekey.offline = false;
      bool auth = await gamekey.authenticate();
      highScore();
    });

    // Login button mouse event
    bt_login.onClick.listen((Event mv) async {
      gamekey = new GameKey(host, port, gameID, gameSecret);//new GameKey("212.201.22.161", 50001, gameID, gameSecret);
      gamekey.offline = false;
      bool auth = await gamekey.authenticate();
      login();
    });

    // Register button mouse event
    bt_register.onClick.listen((Event mv) async{
      gamekey = new GameKey(host, port, gameID, gameSecret);//new GameKey("212.201.22.161", 50001, gameID, gameSecret);
      gamekey.offline = false;
      bool auth = await gamekey.authenticate();
      register();
    });
  }


  /**
   * Register to the Game
   */
  Future register() async{
    final welcome = querySelector("#welcome");

    welcome.innerHtml = "<p id=\"login\">Bitte registriere dich um die Onlinefunktion zu nutzen!</p>" +
        "Loginname: <input id=\"name\" type=\"text\" placeholder=\"Hier Namen eingeben...\"><br>" +
        "Password: <input id=\"password\" type=\"password\" placeholder=\"Hier Passwort eingeben...\"><br>" +
        "Email: <input id=\"mail\" type=\"text\" placeholder=\"Hier Email eingeben...\"><br>" +
        "<input id=\"confirmButton\" type=\"button\" value=\"Register\">" +
        "<p id=\"wrong\" style=\"text-decoration-color: red\"></p>";

    final inputname = querySelector("#name");
    final inputpassword = querySelector("#password");
    final inputemail = querySelector("#mail");
    final stats = querySelector("#stats");
    final inputbutton = querySelector("#confirmButton");
    final score = querySelector("#score");

    String name, password, email = "";

    window. onKeyDown.listen((KeyboardEvent ev) async{
      if(ev.keyCode == KeyCode.ENTER){
        gamekey.username = escape(inputname.value);
        gamekey.userpw = escape(inputpassword.value);
        gamekey.usermail = escape(inputemail.value);

        if(gamekey.available!= false){
          gamekey.params = await gamekey.registerUser(gamekey.username,gamekey.userpw, gamekey.usermail);

          if(gamekey.params == null){
            querySelector("#wrong").innerHtml="Name or Password cannot be Empty or Email is wrong";
            return;
          }
          gamekey.userid = gamekey.params["id"];
        }
        welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
        score.innerHtml="Score:";
        con =  new Controller(gamekey,true, loader.mapData, loader.parameters);
      }
    });

    inputbutton.onClick.listen((MouseEvent ev) async{
      gamekey.username = escape(inputname.value);
      gamekey.userpw = escape(inputpassword.value);
      gamekey.usermail = escape(inputemail.value);

      if(gamekey.available!= false){
        gamekey.params  = await gamekey.registerUser(gamekey.username,gamekey.userpw, gamekey.usermail);

        if(gamekey.params == null){
          querySelector("#wrong").innerHtml="Name, Password or Email is wrong";
          return;
        }
        gamekey.userid = gamekey.params["id"];
      }

      welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
      score.innerHtml="Score:";

      con = new Controller(gamekey, true, loader.mapData, loader.parameters);
    });
  }

  /**
   * Method to login into the Game
   */
  Future login() async{
    final welcome = querySelector("#welcome");

    welcome.innerHtml="<p id=\"login\">Bitte logge Dich ein!</p>" +
        "Loginname: <input id=\"name\" type=\"text\" placeholder=\"Hier Namen eingeben...\"><br>"+
        "Password: <input id=\"password\" type=\"password\" placeholder=\"Hier Passwort eingeben...\"><br>"+
        "<input id=\"confirmButton\" type=\"button\" value=\"Login\">"+
        "<p id=\"wrong\" style=\"text-decoration-color: red\"></p>";

    final level = querySelector("#level");
    final life = querySelector('#life');
    final inputbutton = querySelector("#confirmButton");
    final inputname = querySelector("#name");
    final inputpassword = querySelector("#password");
    final score = querySelector("#score");

    window. onKeyDown.listen((KeyboardEvent ev) async {
      if(ev.keyCode == KeyCode.ENTER){
        if(inputname.value != "" && inputpassword.value != ""){
          gamekey.username = escape(inputname.value);
          gamekey.userpw = escape(inputpassword.value);

          if(gamekey.available!= false) {
            gamekey.userid = await gamekey.getUserId(gamekey.username);

            gamekey.params = await gamekey.getUser(gamekey.userid, gamekey.userpw);

            if(gamekey.params == null){
              querySelector("#wrong").innerHtml="Wrong Data!";
              return;
            }
          }

          welcome.innerHtml = "<input id=\"newGameButton\" type=\"button\" value=\"New Game\"><br>"
              +"<input id=\"loadGameButton\" type=\"button\" value=\"Load Game\"><br>";


          querySelector("#loadGameButton").onClick.listen((Event ev){
            welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
            score.innerHtml="Score:";
            con = new Controller(gamekey,false, loader.mapData, loader.parameters);
          });

          querySelector("#newGameButton").onClick.listen((Event ev){
            welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
            score.innerHtml="Score:";
            con = new Controller(gamekey,true, loader.mapData, loader.parameters);
          });
        }else{
          querySelector("#wrong").innerHtml="Wrong Data!";
        }
      }
    });

    inputbutton.onMouseDown.listen((MouseEvent ev) async {
      if(inputname.value != "" && inputpassword.value != ""){
        gamekey.username = escape(inputname.value);
        gamekey.userpw = escape(inputpassword.value);

        if(gamekey.available!= false) {
          gamekey.userid = await gamekey.getUserId(gamekey.username);
          gamekey.params = await gamekey.getUser(gamekey.userid, gamekey.userpw);

          if(gamekey.params == null){
            querySelector("#wrong").innerHtml="Wrong Data!";
            return;
          }
        }

        welcome.innerHtml = "<input id=\"newGameButton\" type=\"button\" value=\"New Game\"><br>"
            +"<input id=\"loadGameButton\" type=\"button\" value=\"Load Game\"><br>";


        querySelector("#loadGameButton").onClick.listen((Event ev){
          welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
          score.innerHtml="Score:";
          con = new Controller(gamekey,false, loader.mapData, loader.parameters);
        });

        querySelector("#newGameButton").onClick.listen((Event ev){
          welcome.innerHtml = "Spieler: " + gamekey.username + " <input id=\"pauseButton\" type=\"button\" value=\"Pause\">";
          score.innerHtml="Score:";
          con = new Controller(gamekey,true, loader.mapData, loader.parameters);
        });

      }else{
        querySelector("#wrong").innerHtml="User not found!";
      }
    });
  }

  Future highScore() async{
    var gamestates = await gamekey.getStates();
    Map<String, int> map = {};
    String name;
    int points;
    for(var gamestate in gamestates){
      name = gamestate["username"];
      points = gamestate["state"]["points"];
      if(map.containsKey(name)){
        int mappoints = map[name];
        try{
          if(points >= mappoints) map[name] = points;
        }catch(e){}
      } else map[name] = points;
    }
    List list =[];
    for(var key in map.keys){
      if(map[key] == null) map[key] = 0;
      list.add([key,map[key]]);
    }

    list.sort((a,b) => b[1]-a[1]);

    String html = "<p><h1>Highscore</h1></p><table><tr><td>Name</td><td>Score</td></tr>";
    for(var element in list){
      html+="<tr><td>${element[0]}</td><td>${element[1]}</td></tr>";
    }
    html+="</table>";
    querySelector("#nomNomtable").innerHtml=html;
  }

  /**
   * escape HTML Codes
   */
  String escape(String string){
    final htmlescape = const HtmlEscape();
    return htmlescape.convert(string);
  }
}


main() async{
  new Starter();
}

