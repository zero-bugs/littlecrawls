# !/usr/bin/python3
# -*- coding: UTF-8 -*-
from src.db.sq_connection import sqliteManager

if __name__ == "__main__":
    print('hello world')
    sqliteManager.selectImgs()