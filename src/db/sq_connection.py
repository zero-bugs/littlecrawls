#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sqlite3
import threading
from datetime import datetime

from src.common.common_config import CommonConstant
from src.common.constant import time_format
from src.common.db_sql import create_img_table, insert_img_sql, select_img_sql, insert_common_sql, select_common_sql, \
    del_common_sql, create_para_table
from src.model.img_attrib import WallPicAttr


class SqliteManager:
    _instance_lock = threading.Lock()

    def __init__(self, *args, **kwargs):
        # 链接数据库，若数据库不存在则创建
        self.conn = sqlite3.connect(
            "%s" % CommonConstant.db_lib_path, check_same_thread=False
        )
        # 在内存中创建数据库
        # conn = sqlite3.connect(":memory:")
        # 创建游标对象
        self.cur = self.conn.cursor()

        # 创建数据表
        self.cur.execute(create_para_table)
        self.cur.execute(create_img_table)

    @classmethod
    def instance(cls, *args, **kwargs):
        if not hasattr(SqliteManager, "_instance"):
            with SqliteManager._instance_lock:
                if not hasattr(SqliteManager, "_instance"):
                    SqliteManager._instance = SqliteManager(*args, **kwargs)
        return SqliteManager._instance

    def insert_img(self, pic: WallPicAttr):
        if pic is None:
            return False

        try:
            lock.acquire(True)
            self.cur.execute(
                insert_img_sql,
                (
                    pic.id,
                    pic.url,
                    pic.views,
                    pic.favorites,
                    pic.source,
                    pic.purity,
                    pic.category,
                    pic.dimension_x,
                    pic.dimension_y,
                    pic.ratio,
                    pic.file_size,
                    pic.file_type,
                    pic.path,
                    pic.colors,
                    pic.tags,
                    pic.created_time,
                    pic.create_at,
                    pic.update_at,
                ),
            )
            self.conn.commit()
            return True
        except Exception as err:
            print(err)
            self.conn.rollback()
            return False
        finally:
            lock.release()

    def batch_insert_img(self, pics: list):
        if pics is None:
            return False
        elif len(pics) == 0:
            return False
        try:
            lock.acquire(True)
            for pic in pics:
                self.cur.execute(
                    insert_img_sql,
                    (
                        pic.id,
                        pic.url,
                        pic.views,
                        pic.favorites,
                        pic.source,
                        pic.purity,
                        pic.category,
                        pic.dimension_x,
                        pic.dimension_y,
                        pic.ratio,
                        pic.file_size,
                        pic.file_type,
                        pic.path,
                        pic.colors,
                        pic.tags,
                        pic.created_time,
                        pic.create_at,
                        pic.update_at,
                    ),
                )
            else:
                self.conn.commit()
            return True
        except Exception as err:
            print(err)
            self.conn.rollback()
            return False
        finally:
            lock.release()

    def select_images(self, limit=100, offset=0, category=CommonConstant.category_type[2],
                      purity=CommonConstant.purity_type[2]):
        try:
            lock.acquire(True)
            self.cur.execute(
                select_img_sql,
                (
                    category,
                    purity,
                    limit,
                    offset,
                ),
            )
            return self.cur.fetchall()
        except Exception as err:
            print(err)
            self.conn.rollback()
            return None
        finally:
            lock.release()

    def insert_common_tb(self, key, value, description='current cookie'):
        try:
            lock.acquire(True)
            self.cur.execute(
                insert_common_sql,
                (
                    key,
                    value,
                    description,
                    str(datetime.now().strftime(time_format)),
                    str(datetime.now().strftime(time_format)),
                ),
            )
            self.conn.commit()
        except Exception as err:
            print(err)
            self.conn.rollback()
        finally:
            lock.release()

    def select_common_tb(self, index='', key=''):
        try:
            lock.acquire(True)
            self.cur.execute(
                select_common_sql,
                (
                    index,
                    key,
                ),
            )
            return self.cur.fetchall()
        except Exception as err:
            print(err)
            self.conn.rollback()
        finally:
            lock.release()
        return None

    def del_common_tb(self, index=-1, key=''):
        try:
            lock.acquire(True)
            self.cur.execute(
                del_common_sql,
                (
                    index,
                    key,
                ),
            )
            self.conn.commit()
        except Exception as err:
            print(err)
            self.conn.rollback()
        finally:
            lock.release()
        return None

    def close(self):
        self.cur.close()
        self.conn.close()

    def commit(self):
        self.conn.commit()


sqliteManager = SqliteManager()
lock = threading.Lock()
