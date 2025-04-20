import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:write_sdcard_sample/shared/app_dialog.dart';

class PathProviderScreen extends HookWidget {
  const PathProviderScreen({super.key});

  static const String path = '/path_provider';
  static const String name = 'path_provider';

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
                onPressed: () =>
                    _selectDirectoryAndCreateFile(context, directoryPath),
                child: const Text('Select Directory and Create File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on PathProviderScreen {
  Future<void> _selectDirectoryAndCreateFile(
    BuildContext context,
    ValueNotifier<String?> directoryPath,
  ) async {
    final directories = await getExternalStorageDirectories();
    if (directories == null || directories.isEmpty || !context.mounted) {
      return;
    }

    final result = await _showSelectDirectoryModal(context, directories);

    if (!context.mounted) return;
    if (result == null) {
      await showAppDialog(
        context,
        title: 'Directory Selection',
        content: 'No directory was selected.',
      );
      return;
    }

    const localFileSystem = LocalFileSystem();
    // 取得できたパスに NewFolder というフォルダを作成して example.txt を作成する

    try {
      final newFile = localFileSystem
          .directory(result.path)
          .childDirectory('NewFolder')
          .childFile('example.txt')
        ..writeAsStringSync('Hello, USB!');

      await showAppDialog(
        context,
        title: 'Success',
        content: 'Directory selected successfully! '
            '\n path: ${newFile.path}',
      );
      directoryPath.value = newFile.uri.toString();
    } on Exception catch (e) {
      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: 'Error',
        content: 'Failed to create file: $e',
      );
      return;
    }
  }
}

Future<Directory?> _showSelectDirectoryModal(
  BuildContext context,
  List<Directory> directories,
) {
  return showModalBottomSheet<Directory?>(
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (builder) {
      return ListView.separated(
        itemCount: directories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(directories[index].toString()),
            onTap: () => Navigator.pop(context, directories[index]),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          if (index == directories.length - 1) {
            return const SizedBox();
          }
          return const Divider();
        },
      );
    },
  );
}
