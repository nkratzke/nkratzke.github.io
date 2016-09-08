package de.fhl.prog.aufgabe_10_1;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Stack;

/**
 * Ausgabefunktionen fuer Listen, Stacks und Mappings.
 * 
 * @author Nane Kratzke
 */
public abstract class Aufgabe_10_1 {

  /**
   * Erzeugt eine Stringrepräsentation einer Liste.
   * 
   * @param list Liste von Werten v1, v2, ... vn != null
   * @return Zeichenkette "[v1, v2, ..., vn]"
   */
  public static String collection_to_string(List<?> list) {
    String ret = "";
    for (int i = 0; i < list.size(); i++) {
      ret += list.get(i);
      ret += (i < list.size() - 1) ? ", " : "";
    }
    return "[" + ret + "]";
  }

  /**
   * Erzeugt eine Stringrepräsentation eines Kellerspeichers.
   * 
   * @param stack Stack von Werten v1, v2, ... vn != null
   * @return Zeichenkette "[vn, vn-1, ..., v1]"
   */
  public static String collection_to_string(Stack<?> stack) {
    Stack<Object> workingCopy = new Stack<>();
    workingCopy.addAll(stack);
    String ret = "";
    while (!workingCopy.isEmpty()) {
      ret += workingCopy.pop();
      ret += workingCopy.empty() ? "" : ", ";
    }
    return "[" + ret + "]";
  }

  /**
   * Erzeugt eine Stringrepräsentation eines Mappings.
   * 
   * @param map Menge von Key Value Paaren { (k1, v1), (k2, v2), ..., (kn,vn) } != null
   * @return Zeichenkette "[k1 -> v1, k2 -> v2, ..., kn -> vn] (Reihenfolge nicht spezifiziert)
   */
  public static String collection_to_string(Map<?, ?> map) {
    Iterator<?> iterator = map.keySet().iterator();
    String ret = "";
    while (iterator.hasNext()) {
      Object key = iterator.next();
      Object value = map.get(key);
      ret += key + " -> " + value;
      ret += iterator.hasNext() ? ", " : "";
    }
    return "[" + ret + "]";
  }

}
