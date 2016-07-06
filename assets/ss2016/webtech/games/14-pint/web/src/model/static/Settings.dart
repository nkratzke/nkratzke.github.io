/*helper class for holding all the parameters read from the preferences.json
* does not expose the map holding the read settings*/
class Settings{
  /*key-value store read out from the preferences.dart.
  * external accessible only by getter*/
  Map<String, Object> _settings;

  Settings(){
    _settings = new Map<String, Object>();
  }

  Object  get(String key)     { return _settings[key];}
  void    set(Map m)          {_settings = m;}
  bool    contains(String key){return _settings.containsKey(key);}
  void    printKeys() {print('Settings keys\n' + _settings.keys.toString());}
}