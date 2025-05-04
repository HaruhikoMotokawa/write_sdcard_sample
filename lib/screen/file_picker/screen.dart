import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:write_sdcard_sample/shared/app_dialog.dart';

class FilePickerScreen extends HookWidget {
  const FilePickerScreen({super.key});

  static const String path = '/file_picker';
  static const String name = 'file_picker';

  @override
  Widget build(BuildContext context) {
    final directoryPath = useState<String?>(null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                'Directory Path',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                directoryPath.value == null
                    ? 'No directory selected'
                    : directoryPath.value.toString(),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () => _selectDirectory(context, directoryPath),
                child: const Text('Select Directory'),
              ),
              ElevatedButton(
                onPressed: () => _createSubDirAndFile(
                  context,
                  directoryPath.value,
                ),
                child: const Text('Create Sub Directory and File'),
              ),
              ElevatedButton(
                onPressed: () => _readExampleFile(
                  context,
                  directoryPath.value,
                ),
                child: const Text('Read example.txt'),
              ),
              ElevatedButton(
                onPressed: () => _deleteSubDir(
                  context,
                  directoryPath,
                ),
                child: const Text('Delete NewFolder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on FilePickerScreen {
  Future<void> _selectDirectory(
    BuildContext context,
    ValueNotifier<String?> directoryPath,
  ) async {
    final filePicker = FilePicker.platform;
    final path = await filePicker.getDirectoryPath(
      dialogTitle: 'Select Directory',
    );

    if (!context.mounted) return;
    if (path == null) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No directory selected',
      );
      return;
    }
    final fixedPath = _fixDuplicatedEndingInPath(path);
    directoryPath.value = fixedPath;

    await showAppDialog(
      context,
      title: 'Success',
      content: 'Directory selected successfully!'
          '\n fixedPath $fixedPath, path $path',
    );
  }

  Future<void> _createSubDirAndFile(BuildContext context, String? path) async {
    if (path == null) {
      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No directory selected',
      );
      return;
    }
    const localFileSystem = LocalFileSystem();
    final directory = localFileSystem.directory(path);
    final subDir = directory.childDirectory('NewFolder')
      ..createSync(recursive: true);
    final file = subDir.childFile('example.txt')..createSync(recursive: true);
    final fileExists = await file.exists();

    if (!context.mounted) return;
    if (!fileExists) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'File already exists',
      );
      return;
    }

    await file.writeAsString('Hello, world!');

    if (!context.mounted) return;
    await showAppDialog(
      context,
      title: 'Success',
      content: 'File created successfully!',
    );
  }

  Future<void> _readExampleFile(BuildContext context, String? path) async {
    if (path == null) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No file path provided',
      );
      return;
    }

    const localFileSystem = LocalFileSystem();
    final file = localFileSystem
        .directory(path)
        .childDirectory('NewFolder')
        .childFile('example.txt');
    final fileExists = await file.exists();

    if (!context.mounted) return;
    if (!fileExists) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'File does not exist',
      );
      return;
    }

    final content = await file.readAsString();

    if (!context.mounted) return;
    await showAppDialog(
      context,
      title: 'File Content',
      content: content,
    );
  }

  Future<void> _deleteSubDir(
    BuildContext context,
    ValueNotifier<String?> directoryPath,
  ) async {
    if (directoryPath.value == null) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No directory selected',
      );
      return;
    }

    const localFileSystem = LocalFileSystem();
    final directory = localFileSystem.directory(directoryPath.value);
    final subDir = directory.childDirectory('NewFolder');

    if (subDir.existsSync()) {
      subDir.deleteSync(recursive: true);
      directoryPath.value = null;
      await showAppDialog(
        context,
        title: 'Success',
        content: 'Sub-directory deleted successfully!',
      );
    } else {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'Sub-directory does not exist',
      );
    }
  }

  String _fixDuplicatedEndingInPath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();

    final n = parts.length;

    bool listEquals<T>(List<T> a, List<T> b) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    for (var size = n ~/ 2; size >= 1; size--) {
      // Compare two blocks from the end
      final firstBlock = parts.sublist(n - 2 * size, n - size);
      final secondBlock = parts.sublist(n - size, n);

      if (listEquals(firstBlock, secondBlock)) {
        return '/${parts.sublist(0, n - size).join('/')}';
      }
    }

    return path;
  }
}
