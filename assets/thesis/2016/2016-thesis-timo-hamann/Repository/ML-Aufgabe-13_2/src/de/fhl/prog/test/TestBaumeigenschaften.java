package de.fhl.prog.test;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import de.fhl.prog.aufgabe_13_1.Node;
import de.fhl.prog.aufgabe_13_2.Aufgabe_13_2;

/**
 * Test zur Aufgabe 13.2
 * 
 * @author Timo Hamann
 */
public class TestBaumeigenschaften {

  private Node beispielbaum;

  @Before
  public void setUp() {
    beispielbaum = new Node(5, new Node(3, new Node(1, null, null), new Node(4, null, null)),
        new Node(8, new Node(6, null, null),
            new Node(9, null, new Node(37, new Node(17, null, null), new Node(42, null, null)))));
  }

  @Test
  public void testCountNodes_Beispielbaum() {
    Assert.assertEquals(10, Aufgabe_13_2.countNodes(beispielbaum));
  }

  @Test
  public void testCountEdges_Beispielbaum() {
    Assert.assertEquals(9, Aufgabe_13_2.countEdges(beispielbaum));
  }

  @Test
  public void testHeight_Beispielbaum() {
    Assert.assertEquals(5, Aufgabe_13_2.height(beispielbaum));
  }

  @Test
  public void testCountNodes_EinzelnerKnoten() {
    Assert.assertEquals(1, Aufgabe_13_2.countNodes(new Node(42, null, null)));
  }

  @Test
  public void testCountEdges_EinzelnerKnoten() {
    Assert.assertEquals(0, Aufgabe_13_2.countEdges(new Node(42, null, null)));
  }

  @Test
  public void testHeight_EinzelnerKnoten() {
    Assert.assertEquals(1, Aufgabe_13_2.height(new Node(42, null, null)));
  }

}
