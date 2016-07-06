import 'dart:async';
import 'dart:convert';
import 'dart:html';

/*provides connectivity with a gamekey service*/
class GamekeyConnection{
  Uri _uri;
  bool _available;
  String _gid;
  String _secret;
    int answerStatus;

  GamekeyConnection(String host, int port, String gid, String secret){
    _gid = gid;
    _secret = secret;
    _available = true;
    this._uri = new Uri.http("$host:$port", "/");
  }

  /*checks if the gamekey service is available*/
  Future<bool> checkConnection() async {
    try {
      final uri = this._uri.resolve("/game/$_gid").resolveUri(new Uri(queryParameters: { 'secret' : "$_secret" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      if (answer.status == 200) { this._available = true; }
      return answer.status == 200 ? true : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.getGame() caused following error: '$error'");
      print ("$stacktrace");
      //window.alert("GameKey.getGame() caused following error: '$error'");
      this._available = false;
      return false;
    }
  }

  /**
   * Registers a non existing user with the gamekey service.
   * - Returns user map with stored values on success
   * - Returns null if user could not be stored (due to several reasons, gamekey service not reachable, user already existing)
   */
  Future<Map> registerUser(String name, String pwd) async {
    if (!_available) return new Future.value(null);
    try {
      final answer = await HttpRequest.request(
          "${this._uri.resolve("/user")}",
          method: 'POST',
          sendData: parameter({
            'name'   : "$name",
            'pwd' : "$pwd",
          }),
          requestHeaders: {
            'content-type': 'application/x-www-form-urlencoded',
            'charset': 'UTF-8'
          }
      );
      return answer.status == 200 ? JSON.decode(answer.responseText) : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.registerUser() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * Returns detailed user information as Map.
   * Additionally, this method can be used to authenticate a user.
   * A user must know his [id] and his [password].
   */
  Future<Map> getUser(String id, String pwd) async {
    if (!_available) return new Future.value(null);
    try {
      final uri = this._uri.resolve("/user/$id").resolveUri(new Uri(queryParameters: { 'pwd' : "$pwd", 'byname' : "true" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      return answer.status == 200 ? JSON.decode(answer.responseText) : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.getUser() caused following error: '$error'");
      //window.alert('STATUS '+answerStatus.toString() + stacktrace.toString());
      print ("$stacktrace");
      return null;
    }
  }

  /*saves a given state in the gamekey*/
  Future<bool> storeState(String uid, Map state) async {
    if (!_available) return new Future.value(false);
    try {
      final answer = await HttpRequest.request(
          "${this._uri.resolve("/gamestate/$_gid/$uid")}",
          method: 'POST',
          sendData: parameter({
            'secret' : "$_secret",
            'state' : "${JSON.encode(state)}",
          }),
          requestHeaders: {
            'content-type': 'application/x-www-form-urlencoded',
            'charset': 'UTF-8'
          }
      );
      return answer.status == 200 ? true : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.storeState() caused following error: '$error'");
      print ("$stacktrace");
      return false;
    }
  }

  /*loads all states for a user from the gamekey service*/
  Future<List<Map>> getState(String id) async {
    if (!_available) return new Future.value([]);
    try {
      final uri = this._uri.resolve("/gamestate/$_gid/$id").resolveUri(new Uri(queryParameters: { 'secret' : "$_secret" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      return JSON.decode(answer.responseText);
    } catch (error, stacktrace) {
      print ("GameKey.getStates() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }


  /**
   * Helper method to generate parameter body for REST requests.
   */
  static String parameter(Map<String, String> p) => (new Uri(queryParameters: p)).query;
}