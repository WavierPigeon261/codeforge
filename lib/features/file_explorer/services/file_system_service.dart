import 'dart:io';
import 'package:path/path.dart' as p;

class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
  final int size;
  final DateTime lastModified;

  FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
    this.size = 0,
    required this.lastModified,
  });

  String get extension => p.extension(path).toLowerCase();
}

class FileSystemService {
  /// Scans a local directory path and produces a recursive [FileNode] tree structure.
  static Future<FileNode> scanDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final stat = await dir.stat();
    final List<FileNode> children = [];

    try {
      final List<FileSystemEntity> entities = await dir.list(followLinks: false).toList();
      
      // Sort: directories first, then alphabetical order
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
      });

      for (final entity in entities) {
        final baseName = p.basename(entity.path);
        // Ignore hidden git internals or heavy cache dirs if needed
        if (baseName == '.git' || baseName == '.dart_tool' || baseName == 'build') {
          final entityStat = await entity.stat();
          children.add(
            FileNode(
              name: baseName,
              path: entity.path,
              isDirectory: entity is Directory,
              children: [],
              lastModified: entityStat.modified,
            ),
          );
          continue;
        }

        if (entity is Directory) {
          children.add(await scanDirectory(entity.path));
        } else if (entity is File) {
          final fileStat = await entity.stat();
          children.add(
            FileNode(
              name: baseName,
              path: entity.path,
              isDirectory: false,
              size: fileStat.size,
              lastModified: fileStat.modified,
            ),
          );
        }
      }
    } catch (e) {
      // In case of permission errors
    }

    return FileNode(
      name: p.basename(dirPath).isEmpty ? dirPath : p.basename(dirPath),
      path: dirPath,
      isDirectory: true,
      children: children,
      lastModified: stat.modified,
    );
  }

  /// Reads text contents of a file
  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return '';
    try {
      return await file.readAsString();
    } catch (e) {
      return '// Binary or non-UTF8 file content (${e.toString()})';
    }
  }

  /// Writes text contents to a file
  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Creates a new file
  static Future<File> createFile(String parentDirPath, String fileName) async {
    final targetPath = p.join(parentDirPath, fileName);
    final file = File(targetPath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Creates a new folder
  static Future<Directory> createFolder(String parentDirPath, String folderName) async {
    final targetPath = p.join(parentDirPath, folderName);
    final dir = Directory(targetPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Deletes a file or directory
  static Future<void> deleteEntity(String path) async {
    final type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: true);
    } else if (type == FileSystemEntityType.file) {
      await File(path).delete();
    }
  }
}
