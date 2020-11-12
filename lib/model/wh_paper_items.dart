import 'package:json_annotation/json_annotation.dart';

part 'wh_paper_items.g.dart';

class PicType {
  static const String fullSize = 'fullSize';
  static const String thumbnail = 'thumbnail';
}

@JsonSerializable(includeIfNull: false)
class StandardPageItems {
  int currentPage; //page>=2时有值
  int totalPage; //page>=2时有值
  List<StandardPageItem> topListItem;

  StandardPageItems({
    this.currentPage,
    this.totalPage,
    this.topListItem,
  });

  factory StandardPageItems.fromJson(Map<String, dynamic> json) =>
      _$StandardPageItemsFromJson(json);

  Map<String, dynamic> toJson() => _$StandardPageItemsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class StandardPageItem {
  String imgId;
  String favs;
  WallPicAttr fullImg;
  WallPicAttr thumbNailImg;

  StandardPageItem({
    this.imgId,
    this.favs,
    this.fullImg,
    this.thumbNailImg,
  });

  Map<String, dynamic> toJson() => _$StandardPageItemToJson(this);

  factory StandardPageItem.fromJson(Map<String, dynamic> json) =>
      _$StandardPageItemFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class WallPicTag {
  String id;
  String name;
  String alias;
  String href;
  String category;
  String categoryId;
  String purity;
  String createTime;
  String description;

  WallPicTag({
    this.id,
    this.name,
    this.alias,
    this.href,
    this.category,
    this.categoryId,
    this.purity,
    this.createTime,
    this.description,
  });

  factory WallPicTag.fromJson(Map<String, dynamic> json) =>
      _$WallPicTagFromJson(json);

  Map<String, dynamic> toJson() => _$WallPicTagToJson(this);
}

@JsonSerializable(includeIfNull: false)
class WallPicAttr {
  String id;
  String name;
  String type;
  String size;
  String category;
  String purity;
  String viewsCount;
  String favsCount;
  String datetime;
  ImgResolution resolution;
  String resourceHref;
  String downloadLink;
  String relatedHref;
  String description;
  Uploader uploader;
  String uploadTimeDescription;
  List<String> colors;
  List<WallPicTag> tags;

  WallPicAttr({
    this.id,
    this.name,
    this.type,
    this.size,
    this.category,
    this.purity,
    this.viewsCount,
    this.favsCount,
    this.datetime,
    this.resolution,
    this.resourceHref,
    this.downloadLink,
    this.relatedHref,
    this.description,
    this.uploader,
    this.uploadTimeDescription,
    this.colors,
    this.tags,
  });

  factory WallPicAttr.fromJson(Map<String, dynamic> json) =>
      _$WallPicAttrFromJson(json);

  Map<String, dynamic> toJson() => _$WallPicAttrToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ImgResolution {
  String width;
  String height;

  ImgResolution({
    this.width,
    this.height,
  });

  factory ImgResolution.fromJson(Map<String, dynamic> json) =>
      _$ImgResolutionFromJson(json);

  Map<String, dynamic> toJson() => _$ImgResolutionToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Uploader {
  String userName;
  String groupName;
  String avatarImg;
  String avatar;

  Uploader({
    this.userName,
    this.groupName,
    this.avatarImg,
    this.avatar,
  });

  factory Uploader.fromJson(Map<String, dynamic> json) =>
      _$UploaderFromJson(json);

  Map<String, dynamic> toJson() => _$UploaderToJson(this);
}
