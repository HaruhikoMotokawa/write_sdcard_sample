import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:write_sdcard_sample/screen/doc_man/screen.dart';
import 'package:write_sdcard_sample/screen/file_picker/screen.dart';
import 'package:write_sdcard_sample/shared/app_dialog.dart';

part '_extension_2.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({
    super.key,
  });

  static const String path = '/';
  static const String name = 'home';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _ListTile(
                title: DocManScreen.name,
                pushLocation: DocManScreen.path,
              ),
              _ListTile(
                title: FilePickerScreen.name,
                pushLocation: FilePickerScreen.path,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    required this.pushLocation,
  });

  final String title;
  final String pushLocation;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.push(pushLocation),
      ),
    );
  }
}
