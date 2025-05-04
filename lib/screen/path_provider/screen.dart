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
    final directory = useState<Directory?>(null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Provider'),
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
                directory.value == null
                    ? 'No directory selected'
                    : directory.value.toString(),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () => _selectDirectory(context, directory),
                child: const Text('Select Directory and Create File'),
              ),
              ElevatedButton(
                onPressed: () => _createSubDirAndFile(
                  context,
                  directory.value ?? Directory(''),
                ),
                child: const Text('Create Sub Directory and File'),
              ),
              ElevatedButton(
                onPressed: () => _readExampleFile(
                  context,
                  directory.value ?? Directory(''),
                ),
                child: const Text('Read example.txt'),
              ),
              ElevatedButton(
                onPressed: () => _deleteSubDir(
                  context,
                  directory,
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

extension on PathProviderScreen {
  /// ディレクトリの選択
  Future<void> _selectDirectory(
    BuildContext context,
    ValueNotifier<Directory?> directory,
  ) async {
    // デバイスが認識している外部ストレージのディレクトリを取得
    final directories = await getExternalStorageDirectories();
    if (directories == null || directories.isEmpty || !context.mounted) {
      return;
    }

    // ディレクトリ配列を渡して選択ダイアログで表示
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

    // 選択されたディレクトリをuseStateに保存
    directory.value = result;
    await showAppDialog(
      context,
      title: 'Directory Selection',
      content: 'Selected directory: ${result.path}',
    );
  }

  /// サブディレクトリとファイルの作成
  Future<void> _createSubDirAndFile(
    BuildContext context,
    Directory directory,
  ) async {
    if (directory.path.isEmpty) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No directory selected.',
      );
      return;
    }
    const localFileSystem = LocalFileSystem();

    // 選択されたディレクトリにサブディレクトリを作成
    final subDir = localFileSystem
        .directory(directory.path)
        .childDirectory('NewFolder')
      ..createSync(recursive: true);
    if (!subDir.existsSync()) {
      await showAppDialog(
        context,
        title: 'Directory Creation',
        content: 'Failed to create directory.',
      );
      return;
    }

    // サブディレクトリにファイルを作成
    final file = subDir.childFile('hello.txt')
      ..writeAsStringSync('Hello, World!');
    await showAppDialog(
      context,
      title: 'File Creation',
      content: 'File created at: ${file.path}',
    );
  }

  /// ファイルの読み込み
  Future<void> _readExampleFile(
    BuildContext context,
    Directory directory,
  ) async {
    const localFileSystem = LocalFileSystem();
    final file = localFileSystem
        .directory(directory.path)
        .childDirectory('NewFolder')
        .childFile('hello.txt');

    if (file.existsSync()) {
      final content = file.readAsStringSync();
      await showAppDialog(
        context,
        title: 'File Read',
        content: 'File content: $content',
      );
    } else {
      await showAppDialog(
        context,
        title: 'File Not Found',
        content: 'The file does not exist.',
      );
    }
  }

  /// サブディレクトリの削除
  Future<void> _deleteSubDir(
    BuildContext context,
    ValueNotifier<Directory?> directory,
  ) async {
    const localFileSystem = LocalFileSystem();
    final subDir = localFileSystem
        .directory(directory.value?.path ?? '')
        .childDirectory('NewFolder');

    if (subDir.existsSync()) {
      // サブディレクトリを削除
      subDir.deleteSync(recursive: true);
      directory.value = null;
      await showAppDialog(
        context,
        title: 'Directory Deletion',
        content: 'Directory deleted successfully.',
      );
    } else {
      await showAppDialog(
        context,
        title: 'Directory Not Found',
        content: 'The directory does not exist.',
      );
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
