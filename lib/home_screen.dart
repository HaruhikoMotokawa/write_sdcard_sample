import 'dart:typed_data';

import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:write_sdcard_sample/screen/doc_man/screen.dart';
import 'package:write_sdcard_sample/shared/app_dialog.dart';

part '_extension_1.dart';
part '_extension_2.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({
    super.key,
  });

  static const String path = '/';
  static const String name = 'home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: const Text('DocMan Screen'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.push(DocManScreen.path),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
