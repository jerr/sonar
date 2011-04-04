#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package}.language;

import java.util.ArrayList;
import java.util.List;

import org.sonar.api.web.CodeColorizerFormat;
import org.sonar.colorizer.KeywordsTokenizer;
import org.sonar.colorizer.Tokenizer;


public class MyLangCodeColorizerFormat extends CodeColorizerFormat {

  private final List<Tokenizer> tokenizers = new ArrayList<Tokenizer>();

  public MyLangCodeColorizerFormat() {
    super(MyLang.KEY);
    tokenizers.add(new KeywordsTokenizer("<span class=${symbol_escape}"k${symbol_escape}">", "</span>", LgKeywords.get()));
  }

  @Override
  public List<Tokenizer> getTokenizers() {
    return tokenizers;
  }

}
