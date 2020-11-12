import 'package:dtspider/db/sq_lite3_dao.dart';
import 'package:dtspider/model/wh_paper_items.dart';

import 'create_tables.dart';

class WhUploaderDao {
  static final WhUploaderDao _singleInstance = WhUploaderDao._internal();
  WhUploaderDao._internal();
  factory WhUploaderDao() => _singleInstance;

  Future insertUploader(Uploader uploader) async {
    var results = await DBProvider().dbSelectExecute(
      '''select * from $uploaderTable where userName=?''',
      param: ['${uploader?.userName}'],
    );
    if (results.isNotEmpty) {
      print('pic:${uploader.userName} exist, do not insert.');
      return;
    }

    if (uploader != null) {
      var values = [
        uploader?.userName,
        uploader?.groupName,
        uploader?.avatarImg,
        uploader?.avatar,
        DateTime.now().toString(),
        DateTime.now().toString(),
      ];

      return await DBProvider().dbExecute(
          '''insert into $uploaderTable (userName,groupName,avatarImg,avatar,createAt,updateAt) 
        values ("${values[0]}","${values[1]}","${values[2]}","${values[3]}","${values[4]}","${values[5]}")''');
    }
  }
}
