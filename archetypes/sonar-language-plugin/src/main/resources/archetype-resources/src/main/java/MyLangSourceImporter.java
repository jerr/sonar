#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sonar.api.batch.AbstractSourceImporter;
import org.sonar.api.resources.File;
import org.sonar.api.resources.Project;
import org.sonar.api.resources.Resource;
import ${package}.language.MyLang;

/**
 * Import of source files to sonar database.
 */
public class MyLangSourceImporter extends AbstractSourceImporter {

  private static final Logger LOG = LoggerFactory.getLogger(MyLangSourceImporter.class);

  public MyLangSourceImporter(Project project) {
    super(new MyLang(project));
    MyLangPlugin.configureSourceDir(project);
  }
  
  @Override
  public String toString() {
    return getClass().getSimpleName();
  }

}
