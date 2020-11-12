import 'package:json_annotation/json_annotation.dart';

part 'bz_paper_items.g.dart';

@JsonSerializable(includeIfNull: false)
class BzzzzmhItems {
  int current;
  int total;
  int pages;
  int size;
  List<BzzzzmhItem> records;

  BzzzzmhItems({
    this.current,
    this.total,
    this.pages,
    this.size,
    this.records,
  });

  factory BzzzzmhItems.fromJson(Map<String, dynamic> json) =>
      _$BzzzzmhItemsFromJson(json);

  Map<String, dynamic> toJson() => _$BzzzzmhItemsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class BzzzzmhItem {
  String id;
  String width;
  String height;
  String thumbnail;
  String fullImg;

  BzzzzmhItem({
    this.width,
    this.height,
    this.thumbnail,
    this.fullImg,
  });

  Map<String, dynamic> toJson() => _$BzzzzmhItemToJson(this);

  factory BzzzzmhItem.fromJson(Map<String, dynamic> json) =>
      _$BzzzzmhItemFromJson(json);
}
