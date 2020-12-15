# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import json
import time

from src.db.sq_connection import sqliteManager
from src.model.img_attrib import WallPicAttr
from src.utils.http_utils import HttpClient


class ImgServiceApis:
    def scrawPicUseApiAll(self):
        currentPage = 1139
        totalPage = 1140
        while currentPage < totalPage:
            print(
                "begin to scrawl, current page:%d, total page:%d"
                % (currentPage, totalPage)
            )
            val = self.start_search_use_api("", page=currentPage, limit=200)
            print(
                "end with scrawl, current page:%d, total page:%d"
                % (currentPage, totalPage)
            )
            print("..")
            time.sleep(2)
            if val:
                currentPage += 1
                totalPage += 1
            else:
                print(
                    "done with all scrawl, current page:%d, total page:%d"
                    % (currentPage, totalPage)
                )
                break

    def start_search_use_api(self, url, page=1, limit=100):
        print('begin to execute search url:$url')

        headers = dict()
        headers['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36'
        headers['origin'] = '$whUrlAddress'
        headers['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';
        headers['pragma'] = 'no-cache'
        resp = HttpClient.http_retry_executor(url, headers)
        if resp is None:
            print("response is none, url:%s" % (url))
            return False
        elif resp.status_code != 200:
            print("url:%s,status code:%d" % (url, resp.status_code))
            return False

        pics = list()
        for p in json.loads(resp.content):
            pic = WallPicAttr()
            pic.id = p.get("id")
            pic.url = p.get("url")
            pic.views = p.get("views")
            pic.favorites = p.get("favorites")
            pic.source = p.get("source")
            pic.purity = p.get("purity")
            pic.category = p.get("category")
            pic.dimension_x = p.get("dimension_x")
            pic.dimension_y = p.get("dimension_y")
            pic.ratio = p.get("ratio")
            pic.file_size = p.get("file_size")
            pic.file_type = p.get("file_type")
            pic.path = p.get("path")
            pic.colors = p.get("colors")
            pic.tags = ""
            pic.created_time = p.get("create_at")
            pic.source =  0
            pic.source = 0
            pics.append(pic)
        else:
            return sqliteManager.batchInsertImg(pics)