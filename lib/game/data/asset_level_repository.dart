import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/city.dart';
import '../domain/level_definition.dart';
import 'json_reader.dart';
import 'level_index.dart';
import 'level_json_codec.dart';
import 'level_repository.dart';

final class AssetLevelRepository implements LevelRepository {
  AssetLevelRepository(this.bundle, {this.codec = const LevelJsonCodec()});

  final AssetBundle bundle;
  final LevelJsonCodec codec;

  /// The index is read once per repository, not once per city.
  late final Future<LevelIndex> _index = _readJson(
    LevelIndex.fileName,
  ).then(LevelIndex.fromJson);

  @override
  Future<List<LevelDefinition>> loadCity(CityId city) async {
    final index = await _index;
    return [
      for (final file in index.filesFor(city))
        codec.decode(JsonReader(file).object(await _readJson(file), 'level')),
    ];
  }

  Future<Object?> _readJson(String file) async {
    final text = await bundle.loadString('${LevelIndex.assetDir}/$file');
    try {
      return jsonDecode(text);
    } on FormatException catch (e) {
      JsonReader(file).fail('invalid JSON: ${e.message}');
    }
  }
}
