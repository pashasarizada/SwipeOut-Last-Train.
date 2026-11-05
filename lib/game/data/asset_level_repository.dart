import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/level_definition.dart';
import 'level_index.dart';
import 'level_json_codec.dart';
import 'level_repository.dart';

final class AssetLevelRepository implements LevelRepository {
  AssetLevelRepository(this.bundle, {this.codec = const LevelJsonCodec()});

  final AssetBundle bundle;
  final LevelJsonCodec codec;

  @override
  Future<List<LevelDefinition>> loadAll() async {
    final index = LevelIndex.fromJson(
      await _readJson('${LevelIndex.assetDir}/${LevelIndex.fileName}'),
    );
    final levels = [
      for (final file in index.files)
        codec.decode(await _readJson('${LevelIndex.assetDir}/$file')),
    ];
    return levels..sort((a, b) => a.number.compareTo(b.number));
  }

  Future<Map<String, Object?>> _readJson(String path) async =>
      jsonDecode(await bundle.loadString(path)) as Map<String, Object?>;
}
