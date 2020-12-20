class WallPicTag:
    def __init__(self):
        self.id = None
        self.name = None
        self.alias = None
        self.category_id = None
        self.category = None
        self.purity = None
        self.create_time = None
        self.create_at = None
        self.update_at = None


class WallPicAttr:
    def __init__(self):
        self.id = None
        self.url = None
        self.views = 0
        self.favorites = 0
        self.source = None
        self.purity = None
        self.category = None
        self.dimension_x = 0
        self.dimension_y = 0
        self.ratio = 0
        self.file_size = 0
        self.file_type = 'image/jpg'
        self.path = None
        self.colors = list()
        self.tags = list()
        self.created_time = None
        self.create_at = None
        self.update_at = None


class SearchMeta:
    def __init__(self):
        self.current_page = None
        self.last_page = None
        self.per_page = None
        self.total = None
        self.query = None
        self.seed = None
