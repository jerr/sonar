#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.language;

import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.sonar.api.resources.AbstractLanguage;
import org.sonar.api.resources.Project;
import ${package}.MyLangPlugin;

/**
 * This class defines the MyLang language.
 */
public class MyLang extends AbstractLanguage {

  /** All the valid files suffixes. */
  private static final String[] DEFAULT_SUFFIXES = { "lg" };

  /** A MyLang instance. */
  public static final MyLang INSTANCE = new MyLang();

  /** The MyLang language key. */
  public static final String KEY = "lg";

  /** The MyLang language name */
  private static final String MYLANG_LANGUAGE_NAME = "MyLang";

  private String[] fileSuffixes;

  /**
   * Default constructor.
   */
  public MyLang() {
    super(KEY, MYLANG_LANGUAGE_NAME);

    fileSuffixes = DEFAULT_SUFFIXES;
  }

  public MyLang(Project project) {
    this();

    List<?> extensions = project.getConfiguration().getList(MyLangPlugin.FILE_EXTENSIONS);

    if (extensions != null && !extensions.isEmpty() && !StringUtils.isEmpty((String) extensions.get(0))) {
      fileSuffixes = new String[extensions.size()];
      for (int i = 0; i < extensions.size(); i++) {
        fileSuffixes[i] = extensions.get(i).toString().trim();
      }
    } else {
      fileSuffixes = DEFAULT_SUFFIXES;
    }
  }

  /**
   * Gets the file suffixes.
   *
   * @return the file suffixes
   * @see org.sonar.api.resources.Language${symbol_pound}getFileSuffixes()
   */
  public String[] getFileSuffixes() {
    return fileSuffixes;
  }
}
