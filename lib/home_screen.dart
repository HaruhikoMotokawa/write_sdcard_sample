import 'dart:typed_data';

import 'package:docman/docman.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part '_dialog.dart';
part '_extension_1.dart';
part '_extension_2.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final documentFile = useState<DocumentFile?>(null);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                'Document File',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                documentFile.value == null
                    ? 'No document selected'
                    : documentFile.value.toString(),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () => _selectDirectory(context, documentFile),
                child: const Text('DocMan'),
              ),
              ElevatedButton(
                onPressed: () => _createSubDirAndFile(
                  context,
                  documentFile.value?.uri ?? '',
                ),
                child: const Text('Create Sub Directory'),
              ),
              ElevatedButton(
                onPressed: () => _readExampleFile(
                  context,
                  documentFile.value?.uri ?? '',
                ),
                child: const Text('Read example.txt'),
              ),
              ElevatedButton(
                onPressed: () => _deleteSubDir(
                  context,
                  documentFile,
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

extension on HomeScreen {
  Future<void> _selectDirectory(
    BuildContext context,
    ValueNotifier<DocumentFile?> documentFile,
  ) async {
    final documentDirectory = await DocMan.pick.directory();

    if (documentDirectory == null) {
      // 保存に失敗
      if (!context.mounted) return;
      await showAppDialog(context, title: '保存失敗', content: '保存に失敗しました');
    } else {
      // 保存に成功

      documentFile.value = documentDirectory;
      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: '保存成功',
        content: documentDirectory.uri,
      );
    }
  }

  Future<void> _createSubDirAndFile(BuildContext context, String path) async {
    if (path.isEmpty) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: '保存先が選択されていません');
      return;
    }

    try {
      // DocumentFile から既存ディレクトリを取得
      final parentDir = await DocumentFile.fromUri(path);
      if (parentDir == null || !parentDir.isDirectory) {
        if (!context.mounted) return;
        await showAppDialog(context, title: 'エラー', content: '有効なディレクトリではありません');
        return;
      }

      final newDir = await parentDir.createDirectory('NewFolder');

      if (newDir == null) {
        if (!context.mounted) return;
        await showAppDialog(context, title: '作成失敗', content: 'フォルダを作成できませんでした');
        return;
      }
      // New: create example.txt inside the new directory

      await newDir.createFile(
        name: 'example.txt',
        content: 'Hello, i write text from DocMan',
      );

      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: '作成成功',
        content: 'NewFolder と example.txt を作成しました',
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: e.toString());
    }
  }

  Future<void> _readExampleFile(BuildContext context, String path) async {
    if (path.isEmpty) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: '保存先が選択されていません');
      return;
    }

    try {
      final parentDir = await DocumentFile.fromUri(path);
      if (parentDir == null || !parentDir.isDirectory) {
        if (!context.mounted) return;
        await showAppDialog(context, title: 'エラー', content: '無効なディレクトリです');
        return;
      }

      // NewFolder を取得
      final subDir = await parentDir.find('NewFolder');
      if (subDir == null || !subDir.isDirectory) {
        if (!context.mounted) return;
        await showAppDialog(
          context,
          title: '失敗',
          content: 'NewFolder が見つかりません',
        );
        return;
      }

      // example.txt を取得
      final file = await subDir.find('example.txt');
      if (file == null || !file.canRead) {
        if (!context.mounted) return;
        await showAppDialog(
          context,
          title: '失敗',
          content: 'example.txt が読み込めません',
        );
        return;
      }

      // 内容を読み込む
      final bytes = await file.read();
      final content = bytes == null ? '(読み込み失敗)' : String.fromCharCodes(bytes);

      if (!context.mounted) return;
      await showAppDialog(
        context,
        title: 'example.txt',
        content: content,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: e.toString());
    }
  }

  Future<void> _deleteSubDir(
    BuildContext context,
    ValueNotifier<DocumentFile?> file,
  ) async {
    final currentFile = file.value;
    if (currentFile == null) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: '保存先が選択されていません');
      return;
    }

    try {
      final parentDir = await DocumentFile.fromUri(currentFile.uri);
      if (parentDir == null || !parentDir.isDirectory) {
        if (!context.mounted) return;
        await showAppDialog(context, title: 'エラー', content: '無効なディレクトリです');
        return;
      }

      final subDir = await parentDir.find('NewFolder');
      if (subDir == null) {
        if (!context.mounted) return;
        await showAppDialog(
          context,
          title: '失敗',
          content: 'NewFolder が見つかりません',
        );
        return;
      }

      final ok = await subDir.delete();
      if (!ok) {
        if (!context.mounted) return;
        await showAppDialog(context, title: '失敗', content: '削除に失敗しました');
        return;
      }

      if (!context.mounted) return;

      file.value = null;
      await showAppDialog(
        context,
        title: '削除完了',
        content: 'NewFolder と example.txt を削除しました',
      );

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!context.mounted) return;
      await showAppDialog(context, title: 'エラー', content: e.toString());
    }
  }
}
