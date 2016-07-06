import 'dart:html';
import 'dart:convert';
import 'start.dart';

/**
 * Implements loading data from server
 */
class DataLoader {

  // load flags
  bool mapLoaded = false;
  bool gameKeyLoaded = false;
  bool parametersLoaded = false;

  // game data
  Map mapData;
  Map parameters;
  Map gamekeyData;

  // game start class
  Starter starter;

  // constants
  final BASE_URL = "http://localhost:63342/webtech2016/web/";
  final GAMEKEY_URL = "gamekey.json";
  final MODEL_URL = "parameter.json";
  final MAP_URL = "fielddata.json";


  /**
   * Constructor
   */
  DataLoader(this.starter) {}

  /**
   * Loading data from the server
   */
  void loadData() {
    print("Loading data...");
    var url = BASE_URL + GAMEKEY_URL;
    HttpRequest.getString(url).then(onGameKeyLoad);

    url = BASE_URL + MODEL_URL;
    HttpRequest.getString(url).then(onParameterLoad);

    url = BASE_URL + MAP_URL;
    HttpRequest.getString(url).then(onMapLoad);
  }

  /**
   * Function is called when server response
   */
  void onMapLoad(String responseText){
    this.mapData = JSON.decode(responseText);

    print("Mapdata loaded");
    this.mapLoaded = true;
    checkFinished();
  }

  /**
   * Function is called when server response
   */
  void onGameKeyLoad(String responseText){
    this.gamekeyData = JSON.decode(responseText);

    print("Gamekeydata loaded");
    this.gameKeyLoaded = true;
    checkFinished();
  }

  /**
   * Function is called when server response
   */
  void onParameterLoad(String responseText){
    this.parameters = JSON.decode(responseText);

    print("Parameters loaded");
    this.parametersLoaded = true;
    checkFinished();
  }

  /**
   * Function is called when all requests responded
   */
  void checkFinished(){
    if(mapLoaded && gameKeyLoaded && parametersLoaded)
      this.starter.startGame();
  }

}
