// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The ML_Web_Erathosthenes library.
library ML_Web_Erathosthenes;

import 'dart:math';

/**
 * Generates all prime numbers until n.
 * Returns them as a List.
 * Check: http://de.wikipedia.org/wiki/Sieb_des_Eratosthenes
 */
List<int> prims(int n) {
  var ret = [];
  var gestrichen = new Iterable.generate(n + 1, (i) => i == 0 || i == 1 ? true : false).toList();
  for (int i = 2; i <= sqrt(n); i++) {
    if (!gestrichen[i]) {
      ret.add(i);
      for (int j = i * i; j <= n; j += i) {
        gestrichen[j] = true;
      }
    }
  }
  for (int i = sqrt(n).floor() + 1; i <= n; i++) {
    if (!gestrichen[i]) { ret.add(i); }
  }
  return ret;
}

/**
 * Generates from a list of objects [ns] a HTML table
 * with [cols] columns. The table is assigned a class [c].
 * [ns] must be not null.
 * [cols] must be greater zero.
 * [c] defaults to 'eratosthenes'.
 */
String toHtmlTable(List ns, int cols, [String c = 'eratosthenes']) {
  String tab = "\n";
  while (ns.isNotEmpty) {
    tab += "<tr>${ ns.take(cols).map((n) => "<td>$n</td>").join() }</tr>\n";
    ns.removeRange(0, min(cols, ns.length));
  }
  return "<table class='$c'>$tab</table>";
}