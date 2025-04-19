part of 'home_screen.dart';

extension on HomeScreen {
  Future<void> _onTapWithFilePickerAndLocalFileSystem(
    BuildContext context,
  ) async {
    final filePicker = FilePicker.platform;
    // Get the external storage directory
    final directoryPath = await filePicker.getDirectoryPath(
      dialogTitle: 'Select Directory',
    );

    if (!context.mounted) return;
    if (directoryPath == null) {
      await showAppDialog(
        context,
        title: 'Error',
        content: 'No directory selected',
      );
      return;
    }
    try {
      final fixedPath = _fixDuplicatedEndingInPath(directoryPath);
      const localFileSystem = LocalFileSystem();
      localFileSystem
          .directory(fixedPath)
          .childFile('example.txt')
          .writeAsStringSync('Hello, SD Card!');
      if (!context.mounted) return;
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
