import 'package:dtspider/common/config.dart';
import 'package:dtspider/db/create_tables.dart';
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

DynamicLibrary _openOnWindows() {
  // final script = File(Platform.pascript.toFilePath(windows: true));
  final libraryNextToScript = File(DB_LIB_DLL);
  return DynamicLibrary.open(libraryNextToScript.path);
}

class DBProvider {
  static final DBProvider _singleton = DBProvider._internal();
  DBProvider._internal();
  factory DBProvider() => _singleton;

  static Database _db;

  initDB() async {
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
    _db = sqlite3.open(WALL_DB_NAME);

    await _db.execute(createCommonInfoTable);
    await _db.execute(createFullPicAttrTable);
    await _db.execute(createThumbPicAttrTable);
    await _db.execute(createUploaderTable);
    await _db.execute(createTagTable);

    print('init db success.');
  }

  dispose() async {
    await _db.dispose();
  }

  dbExecute(sql) async {
    try {
      await _db.execute(sql);
    } on SqliteException catch (e) {
      if (e.message.contains('UNIQUE constraint failed')) {
        print('insert data failed for reason:${e.message}, sql:$sql');
        // TODO if update data.
      } else {
        print('insert error:$e, sql:$sql');
      }
    }
  }

  Future<ResultSet> dbSelectExecute(sql, {List<Object> param}) async {
    ResultSet res;
    try {
      res = await _db.select(sql, param);
    } on SqliteException catch (e) {
      print(
          'select failed, sql:$sql, param:${param.toString()},e:${e.toString()}');
    }
    return res;
  }
}
