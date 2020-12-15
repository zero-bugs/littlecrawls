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
        self.views = None
        self.favorites = None
        self.source = None
        self.purity = None
        self.category = None
        self.dimension_x = None
        self.dimension_y = None
        self.resolution = None
        self.ratio = None
        self.file_size = None
        self.file_type = None
        self.path = None
        self.colors = list()
        self.tags = list()
        self.created_time = None
        self.create_at = None
        self.update_at = None
