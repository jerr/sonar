package org.sonar.plugins.mylang.language;


import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public final class LgKeywords {

  private static final Set<String> KEYWORDS = new HashSet<String>();

  private static final String[] LG_KEYWORDS = new String[] { "if", "then", "else", "end", "do", "loop", "for", "next"};

  static {
    Collections.addAll(KEYWORDS, LG_KEYWORDS);
  }

  private LgKeywords() {
  }

  public static Set<String> get() {
    return Collections.unmodifiableSet(KEYWORDS);
  }
}
