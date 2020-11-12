const String fullPicAttrTable = 'fullpicattr';
const String thumbPicAttrTable = 'thumbpicattr';
const String uploaderTable = 'uploader';
const String tagTable = 'wallpictag';
const String commonInfoTable = 'commoninfo';

final String createFullPicAttrTable = ''' 
create table if not exists '${fullPicAttrTable}' (
  id TEXT not null primary key,
  name TEXT,
  type TEXT,
  size TEXT,
  category TEXT,
  purity TEXT,
  viewsCount TEXT,
  favsCount TEXT,
  datetime TEXT,
  resolution ImgResolution,
  resourceHref TEXT,
  downloadLink TEXT,
  relatedHref TEXT,
  description TEXT,
  uploaderName TEXT,
  uploadTimeDescription TEXT,
  colors TEXT,
  tags TEXT,
  createAt TEXT,
  updateAt TEXT
);
''';

final String createThumbPicAttrTable = ''' 
create table if not exists '${thumbPicAttrTable}' (
  id TEXT not null primary key,
  name TEXT,
  type TEXT,
  size TEXT,
  category TEXT,
  purity TEXT,
  viewsCount TEXT,
  favsCount TEXT,
  datetime TEXT,
  resolution ImgResolution,
  resourceHref TEXT,
  downloadLink TEXT,
  relatedHref TEXT,
  description TEXT,
  uploaderName TEXT,
  uploadTimeDescription TEXT,
  colors TEXT,
  tags TEXT,
  createAt TEXT,
  updateAt TEXT
);
''';

final String createUploaderTable = ''' 
create table if not exists '${uploaderTable}' (
  userName TEXT not null primary key,
  groupName TEXT,
  avatarImg TEXT,
  avatar TEXT,
  createAt TEXT,
  updateAt TEXT
);
''';

final String createTagTable = ''' 
create table if not exists '${tagTable}' (
  id TEXT not null primary key,
  name TEXT,
  alias TEXT,
  href TEXT,
  category TEXT,
  categoryId TEXT,
  purity TEXT,
  createTime TEXT,
  description TEXT,
  createAt TEXT,
  updateAt TEXT
);
''';

final String createCommonInfoTable = ''' 
create table if not exists '${commonInfoTable}' (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT,
  value TEXT,
  description TEXT,
  createAt TEXT,
  updateAt TEXT
);
''';
