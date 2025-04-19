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
      appBar: AppBar(),
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
                onPressed: () =>
                    _selectDirectoryAndCreateFile(context, directoryPath),
                child: const Text('Select Directory and Create File'),
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: const Text('Read example.txt'),
              // ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: const Text('Delete NewFolder'),
              // ),
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
    // Get the external storage directory
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

  Future<void> _selectDirectoryAndCreateFile(
    BuildContext context,
    ValueNotifier<String?> directoryPath,
  ) async {
    final filePicker = FilePicker.platform;
    // Get the external storage directory
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
    try {
      final fixedPath = _fixDuplicatedEndingInPath(path);
      const localFileSystem = LocalFileSystem();
      localFileSystem
          .directory(fixedPath)
          .childFile('example.txt')
          .writeAsStringSync('Hello, SD Card!');
      if (!context.mounted) return;

      directoryPath.value = fixedPath;
      await showAppDialog(
        context,
        title: 'Success',
        content: 'File written successfully!',
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: 'Error',
        content: e.toString(),
      );
    }
  }

  /// FilePickerで取得できるパス
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
