package org.sonar.plugins.mylang;

import org.sonar.api.Plugin;

import java.util.ArrayList;
import java.util.List;

import org.sonar.api.Extension;
import org.sonar.api.Plugin;
import org.sonar.api.Properties;
import org.sonar.api.Property;
import org.sonar.api.resources.Project;
import org.sonar.plugins.mylang.language.MyLang;
import org.sonar.plugins.mylang.language.MyLangCodeColorizerFormat;

/**
 * This class is the entry point for all extensions
 */
@Properties({
		@Property(key = MyLangPlugin.FILE_EXTENSIONS, name = "File extensions", description = "List of file extensions that will be scanned.", defaultValue = "lg", global = true, project = true),
		@Property(key = MyLangPlugin.SOURCE_DIRECTORY, name = "Source directory", description = "Source directory that will be scanned.", defaultValue = "src/main/mylang", global = false, project = true) })
public class MyLangPlugin implements Plugin {

	public static final String KEY = "sonar-mylang-plugin";
	public static final String FILE_EXTENSIONS = "sonar.mylang.fileExtensions";
	public static final String SOURCE_DIRECTORY = "sonar.mylang.sourceDirectory";

	public static void configureSourceDir(Project project) {
		String sourceDir = (String) project.getProperty(SOURCE_DIRECTORY);
		if (sourceDir != null) {
			project.getFileSystem().getSourceDirs().clear();
			project.getFileSystem().addSourceDir(
					project.getFileSystem().resolvePath(sourceDir));
		}
	}

	/**
	 * @deprecated this is not used anymore
	 */
	public String getKey() {
		return KEY;
	}

	/**
	 * @deprecated this is not used anymore
	 */
	public String getName() {
		return "My Sonar language plugin";
	}

	/**
	 * @deprecated this is not used anymore
	 */
	public String getDescription() {
		return "You shouldn't expect too much from this plugin except displaying the Hello World message.";
	}

	// This is where you're going to declare all your Sonar extensions
	public List getExtensions() {
		List<Class<? extends Extension>> list = new ArrayList<Class<? extends Extension>>();

		// MyLang language
		list.add(MyLang.class);
		// Source importer
		list.add(MyLangSourceImporter.class);
		// Source Code Colorizer
		list.add(MyLangCodeColorizerFormat.class);

		return list;
	}

	@Override
	public String toString() {
		return getClass().getSimpleName();
	}
}