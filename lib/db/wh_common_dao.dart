import 'package:dtspider/db/sq_lite3_dao.dart';
import 'package:dtspider/utils/utils.dart';
import 'package:sqlite3/sqlite3.dart';

import 'create_tables.dart';

class CommonInfoDao {
  static final CommonInfoDao _singleInstance = CommonInfoDao._internal();
  CommonInfoDao._internal();
  factory CommonInfoDao() => _singleInstance;

  Future insertCommonInfo(
      {String key, String value, String description}) async {
    if (isEmpty(key) || isEmpty(value)) {
      print('input key or value is null');
      return;
    }

    var values = [
      key,
      value,
      description,
      DateTime.now().toString(),
      DateTime.now().toString()
    ];

    return await DBProvider().dbExecute(
      '''insert into $commonInfoTable (key,value,description,createAt,updateAt) 
        values ("${values[0]}","${values[1]}","${values[2]}","${values[3]}","${values[4]}")''',
    );
  }

  Future<ResultSet> selectCommonInfo(String key) async {
    return await DBProvider().dbSelectExecute(
      '''select * from $commonInfoTable where key=?''',
      param: [key],
    );
  }

  deleteCommonInfo(int id) async {
    await DBProvider().dbExecute(
      '''delete from $commonInfoTable where id=$id''',
    );
  }
}
