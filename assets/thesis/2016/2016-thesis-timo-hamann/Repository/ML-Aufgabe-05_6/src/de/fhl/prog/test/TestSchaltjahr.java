package de.fhl.prog.test;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameter;
import org.junit.runners.Parameterized.Parameters;

import de.fhl.prog.aufgabe_05_6.Aufgabe_05_6;

/**
 * Test zur Aufgabe 5.6
 * 
 * @author Timo Hamann
 */
@RunWith(value = Parameterized.class)
public class TestSchaltjahr extends AbstractConsoleTest {

  @Parameter
  public Entry<Integer, Boolean> parameter;

  /**
   * @return Testdaten des {@link Parameterized parametrisierten} Tests
   * @see #test()
   */
  @Parameters(name = "{0}")
  public static Set<Entry<Integer, Boolean>> data() {
    Map<Integer, Boolean> data = new HashMap<>();
    data.put(2011, false);
    data.put(2012, true);
    data.put(2013, false);
    data.put(2014, false);
    data.put(2015, false);
    data.put(2016, true);
    data.put(2017, false);

    data.put(1500, false);
    data.put(1600, true);
    data.put(1700, false);
    data.put(1800, false);
    data.put(1900, false);
    data.put(2000, true);
    data.put(2100, false);
    return data.entrySet();
  }

  /**
   * Testet einen Testparameter.
   * 
   * @see #parameter
   */
  @Test
  public void test() {
    int year = parameter.getKey();
    boolean expectedResult = parameter.getValue();

    writeToConsole(String.valueOf(year));
    Aufgabe_05_6.main(null);
    String consoleOutput = readFromConsole();
    StringBuilder expectedStringBuilder = new StringBuilder();
    expectedStringBuilder.append(year);
    expectedStringBuilder.append(" ist ");
    expectedStringBuilder.append(expectedResult ? "ein" : "kein");
    expectedStringBuilder.append(" Schaltjahr.");
    Assert.assertTrue(consoleOutput.trim().endsWith(expectedStringBuilder.toString()));
  }

}
