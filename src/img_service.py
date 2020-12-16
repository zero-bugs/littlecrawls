# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import datetime
import json
import time

from src.common.common_config import CommonConstant
from src.common.constant import time_format
from src.db.sq_connection import sqliteManager
from src.model.img_attrib import WallPicAttr, SearchMeta
from src.utils.http_utils import HttpClient


class ImgServiceApis:
    def scrawPicUseApiAll(self):
        currentPage = 1
        totalPage = 1
        while currentPage <= totalPage:
            print(
                "begin to request, current page:%d, total page:%d"
                % (currentPage, totalPage)
            )

            url = "{}/api/v1/search?apikey={}&categories={}&purity={}&page={}".format(
                CommonConstant.wall_haven_url,
                CommonConstant.api_key,
                CommonConstant.api_category,
                CommonConstant.api_purity,
                currentPage,
            )
            meta = self.start_search_use_api(url)
            print(
                "end with scrawl, current page:%d, total page:%d"
                % (currentPage, totalPage)
            )
            print("..")

            time.sleep(1)

            currentPage += 1
            totalPage = meta.last_page

            print(
                "done with all api search, current page:%d, total page:%d"
                % (currentPage, totalPage)
            )

    def start_search_use_api(self, url):
        print("begin to execute search url:{}".format(url))

        headers = dict()
        headers[
            "user-agent"
        ] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
        headers["origin"] = "$whUrlAddress"
        headers[
            "accept"
        ] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        headers["pragma"] = "no-cache"
        resp = HttpClient.http_retry_executor(url, headers)
        if resp is None:
            print("response is none, url:%s" % (url))
            return False
        elif resp.status_code != 200:
            print("url:%s,status code:%d" % (url, resp.status_code))
            return False

        pics = list()
        respJson = json.loads(resp.content)

        meta = SearchMeta()
        meta.current_page = respJson.get("meta").get("current_page")
        meta.last_page = respJson.get("meta").get("last_page")
        meta.per_page = respJson.get("meta").get("per_page")
        meta.total = respJson.get("meta").get("total")
        meta.query = respJson.get("meta").get("query")
        meta.seed = respJson.get("meta").get("seed")

        for p in respJson.get("data"):
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
            pic.created_time = p.get("created_at")
            pic.create_at = datetime.datetime.now().strftime(time_format)
            pic.update_at = datetime.datetime.now().strftime(time_format)
            pics.append(pic)
        else:
            sqliteManager.batchInsertImg(pics)

        return meta
