import 'package:dtspider/model/wh_paper_items.dart';

import 'create_tables.dart';
import 'sq_lite3_dao.dart';

class WhTagDao {
  static final WhTagDao _singleInstance = WhTagDao._internal();
  WhTagDao._internal();
  factory WhTagDao() => _singleInstance;

  Future insertTags(List<WallPicTag> tags) async {
    if (tags != null) {
      tags.forEach((element) async {
        var values = [
          element.id,
          element.name,
          element.alias,
          element.href,
          element.category,
          element.categoryId,
          element.purity,
          element.createTime,
          element.description,
          DateTime.now().toString(),
          DateTime.now().toString(),
        ];
        await DBProvider().dbExecute(
            '''insert into $tagTable (id,name,alias,href,category,categoryId,purity,createTime,Description,createAt,updateAt) 
            values ("${values[0]}","${values[1]}","${values[2]}","${values[3]}","${values[4]}","${values[5]}","${values[6]}","${values[7]}","${values[8]}","${values[9]}","${values[10]}")''');
      });
    }
  }
}
