part of 'home_screen.dart';

/// ダメだったやつ
extension on HomeScreen {
  Future<void> _onTapWithFlutterFileSaver(
    BuildContext context,
    ValueNotifier<String?> saveDirectoryPath,
  ) async {
    final bytes = Uint8List.fromList('こんにちは、USB!'.codeUnits);

    final path = await FlutterFileSaver().writeFileAsBytes(
      fileName: 'example.txt', // デフォルト名
      bytes: bytes, // 保存したいデータ
    );

    if (path.isEmpty) {
      // 保存に失敗
      if (!context.mounted) return;
      await showAppDialog(context, title: '保存失敗', content: '保存に失敗しました');
    } else {
      // 保存に成功
      saveDirectoryPath.value = path;
      if (!context.mounted) return;
      await showAppDialog(context, title: '保存成功', content: path);
    }

    saveDirectoryPath.value = path;
  }
}
