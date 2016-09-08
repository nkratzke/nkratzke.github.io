package de.fhl.prog.test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.TreeMap;

import org.junit.Assert;
import org.junit.Test;

import de.fhl.prog.aufgabe_10_1.Aufgabe_10_1;

/**
 * Test zur Aufgabe 10.1
 * 
 * @author Timo Hamann
 */
public class TestAusgaberoutinen {

  @Test
  public void testEmptyList() {
    Assert.assertEquals("[]", Aufgabe_10_1.collection_to_string(Collections.emptyList()));
  }

  @Test
  public void testList() {
    List<Integer> list = Arrays.asList(1, 4, 3, 2, 5);
    List<Integer> workingCopy = new ArrayList<>(list);

    Assert.assertEquals("[1, 4, 3, 2, 5]", Aufgabe_10_1.collection_to_string(workingCopy));
    Assert.assertEquals("Der Inhalt der Datenstruktur wurde veraendert!", list, workingCopy);
  }

  @Test
  public void testEmptyStack() {
    Assert.assertEquals("[]", Aufgabe_10_1.collection_to_string(new Stack<>()));
  }

  @Test
  public void testStack() {
    Stack<Integer> stack = new Stack<>();
    stack.addAll(Arrays.asList(1, 4, 3, 2, 5));
    Stack<Integer> workingCopy = new Stack<>();
    workingCopy.addAll(stack);

    Assert.assertEquals("[5, 2, 3, 4, 1]", Aufgabe_10_1.collection_to_string(workingCopy));
    Assert.assertEquals("Der Inhalt der Datenstruktur wurde veraendert!", stack, workingCopy);
  }

  @Test
  public void testEmptyMap() {
    Assert.assertEquals("[]", Aufgabe_10_1.collection_to_string(Collections.emptyMap()));
  }

  @Test
  public void testMap() {
    Map<Integer, Character> map = new TreeMap<>();
    for (int i = 65; i < 70; i++) {
      map.put(i, (char) i);
    }
    Map<Integer, Character> workingCopy = new TreeMap<>(map);

    Assert.assertEquals("[65 -> A, 66 -> B, 67 -> C, 68 -> D, 69 -> E]",
        Aufgabe_10_1.collection_to_string(workingCopy));
    Assert.assertEquals("Der Inhalt der Datenstruktur wurde veraendert!", map, workingCopy);
  }

}
