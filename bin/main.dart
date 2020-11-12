import 'package:dtspider/db/sq_lite3_dao.dart';
import 'package:dtspider/db/wh_picattr_dao.dart';
import 'package:dtspider/wallpaper/sp_wall_haven.dart';
import 'package:dtspider/wallpaper/sp_wall_login.dart';

main() async {
  // // var pic = await getFullSizeImage(url: 'https://wallhaven.cc/w/zm1p2j');
  await DBProvider().initDB();

  // login in wall haven
  // await loginWallHaven();

  // main
  // await startSpiderHottestThumbPic();
  // await startSpiderTopListThumbPic();
  // await startSpiderLatestThumbPic();

  // var img = await getFullSizeImage(url: 'https://wallhaven.cc/w/963gkk');
  // print(img);
  // await WhPicAttrDao().insertOneImage(img);
  // await startSpiderFullSizeImg();

  // await startDownloadFullSizeImg(purity: 'sketchy', offset: 4040);

  //total 165436
  await startDownloadFullSizeImg(purity: 'nsfw', offset: 101899);
}
