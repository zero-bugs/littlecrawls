import 'package:dtspider/db/wh_tag_dao.dart';
import 'package:dtspider/db/wh_uploader_dao.dart';
import 'package:dtspider/model/wh_paper_items.dart';
import 'package:dtspider/utils/utils.dart';

import 'create_tables.dart';
import 'wh_common_dao.dart';
import 'wh_constant.dart';

class WhDbServiceImpl {
  Future insertAllImgsToDb(StandardPageItem picAttrItem) async {
    await insertOneImage(picAttrItem.fullImg, tableName: '$fullPicAttrTable');
    await insertOneImage(picAttrItem.thumbNailImg,
        tableName: '$thumbPicAttrTable');
    await WhTagDao().insertTags(picAttrItem.fullImg.tags);
    await WhUploaderDao().insertUploader(picAttrItem.fullImg.uploader);
  }

  Future insertOneImage(
    WallPicAttr picAttr, {
    String tableName: '${fullPicAttrTable}',
  }) async {
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
  }

  Future<String> getCookie() async {
    var res = await CommonInfoDao().selectCommonInfo('$cookieKey');
    String cookie = '';
    res?.forEach((row) {
      if (!isEmpty(row['updateAt'])) {
        if (DateTime.now()
                .difference(DateTime.parse(row['updateAt']))
                .inMinutes <=
            90) {
          cookie = row['value'];
        } else {
          CommonInfoDao().deleteCommonInfo(row['id']);
        }
      }
    });

    return cookie;
  }

  Future insertCookieInfo(String cookie) async {
    return await CommonInfoDao().insertCommonInfo(
        key: '$cookieKey', value: cookie, description: 'wall haven cookie');
  }
}
