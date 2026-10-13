import 'dart:io';

void main() {
  final Directory libDir = Directory('lib');
  final String importLine = "import 'package:tscan/l10n/app_localizations.dart';";

  void processFile(File file) {
    String content = file.readAsStringSync();
    if (content.contains('AppLocalizations') && 
        !content.contains('app_localizations.dart') && 
        !file.path.endsWith('app_localizations.dart') &&
        !file.path.endsWith('app_localizations_en.dart') &&
        !file.path.endsWith('app_localizations_tr.dart')) {
      
      // Find the last import
      List<String> lines = content.split('\n');
      int lastImportIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().startsWith('import ')) {
          lastImportIndex = i;
        }
      }

      if (lastImportIndex != -1) {
        lines.insert(lastImportIndex + 1, importLine);
      } else {
        // No imports found, insert at top (after any comments)
        int firstCodeLine = 0;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].trim().isNotEmpty && !lines[i].trim().startsWith('//')) {
            firstCodeLine = i;
            break;
          }
        }
        lines.insert(firstCodeLine, '$importLine\n');
      }

      file.writeAsStringSync(lines.join('\n'));
      print('Added import to ${file.path}');
    }
  }

  void walkDir(Directory dir) {
    for (var entity in dir.listSync()) {
      if (entity is Directory) {
        walkDir(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        processFile(entity);
      }
    }
  }

  walkDir(libDir);
}
