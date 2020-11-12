import 'package:dtspider/model/wh_paper_items.dart';
import 'package:dtspider/utils/utils.dart';

import 'create_tables.dart';
import 'sq_lite3_dao.dart';

class WhPicAttrDao {
  static final WhPicAttrDao _singleInstance = WhPicAttrDao._internal();

  WhPicAttrDao._internal();

  factory WhPicAttrDao() => _singleInstance;

  Future insertOneImage(
    WallPicAttr picAttr, {
    String tableName: '${fullPicAttrTable}',
  }) async {
    var results = await DBProvider().dbSelectExecute(
      '''select * from $tableName where id=?''',
      param: ['${picAttr?.id}'],
    );
    if (results.isNotEmpty) {
      print('pic:${picAttr.resourceHref} exist, do not insert.');
      return;
    }

    var values = [
      picAttr.id,
      picAttr.name,
      picAttr.type,
      picAttr.size,
      picAttr.category,
      picAttr.purity,
      picAttr.viewsCount,
      picAttr.favsCount,
      picAttr.datetime,
      picAttr.resolution?.toJson(),
      picAttr.resourceHref,
      picAttr.downloadLink,
      picAttr.relatedHref,
      picAttr.description,
      picAttr.uploader?.userName,
      picAttr.uploadTimeDescription,
      picAttr.colors?.map((e) => e),
      picAttr.tags?.map((e) => e.id),
      DateTime.now().toString(),
      DateTime.now().toString(),
    ];
    await DBProvider().dbExecute(
        '''insert into '${tableName}' (id,name,type,size,category,purity,viewsCount,favsCount,datetime,resolution,resourceHref,downloadLink,relatedHref,description,uploaderName,uploadTimeDescription,colors,tags,createAt,updateAt) 
        values ("${values[0]}","${values[1]}","${values[2]}","${values[3]}","${values[4]}","${values[5]}","${values[6]}","${values[7]}","${values[8]}","${values[9]}","${values[10]}","${values[11]}","${values[12]}","${values[13]}","${values[14]}","${values[15]}","${values[16]}","${values[17]}","${values[18]}","${values[19]}")''');
  }

  Future<List<String>> getFullPicResourceRefFromThumbTab({
    int limit: 100,
    int offset: 0,
  }) async {
    var results = await DBProvider().dbSelectExecute(
        'select * from $thumbPicAttrTable limit $limit offset $offset');
    List<String> urls = List<String>();
    results.forEach((row) {
      urls.add(row['resourceHref']);
    });

    return urls;
  }

  // purity:sfw/nsfw/sketchy
  // category: anime/general/people
  Future<List<WallPicAttr>> getFullPicUrlromFullTab({
    int limit: 100,
    int offset: 0,
    String category,
    String purity,
  }) async {
    var sql = 'select * from $fullPicAttrTable ';
    if (!isEmpty(category)) {
      sql += 'where category="$category" ';
    }

    if (!isEmpty(purity)) {
      sql += (sql.contains('where')
          ? 'and purity="$purity" '
          : 'where purity="$purity" ');
    }
    sql += 'limit $limit offset $offset';

    print('sql:$sql');
    var results = await DBProvider().dbSelectExecute(sql);

    List<WallPicAttr> imgs = List<WallPicAttr>();
    results.forEach((row) {
      WallPicAttr img = WallPicAttr(
        id: row['id'],
        downloadLink: row['downloadLink'],
        category: row['category'],
        purity: row['purity'],
      );
      imgs.add(img);
    });

    return imgs;
  }
}
