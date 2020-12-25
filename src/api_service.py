# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import datetime
import json
import os
import threading
import time

from src.common.common_config import CommonConstant
from src.common.constant import time_format
from src.db.sq_connection import sqliteManager
from src.model.img_attrib import WallPicAttr, SearchMeta
from src.utils.http_utils import httpClient

historyImgList = []


class ImgServiceApis:
    def init(self):
        with open(CommonConstant.download_img_list) as f:
            for line in f.readlines():
                historyImgList.append(line.strip())
        print(f"init completed, history file count:{len(historyImgList)}")

    def scrawl_img_use_api_all(self, current_page=1, total_page=10000, category=CommonConstant.category_type[2],
                               purity=CommonConstant.purity_type[2]):
        current_page = current_page
        total_page = total_page
        while current_page <= total_page:
            print(
                f"{threading.current_thread().name}-begin to request, current page:{current_page}, total page:{total_page}"
            )

            url = "{}/api/v1/search?apikey={}&categories={}&purity={}&page={}".format(
                CommonConstant.wall_haven_url,
                CommonConstant.api_key,
                category,
                purity,
                current_page,
            )
            meta = self.start_search_use_api(url)
            print(
                f"{threading.current_thread().name}-end with scrawl, current page:{current_page}, total page:{total_page}"
            )
            print("..")

            time.sleep(2)

            current_page += 1
            total_page = meta.last_page

            print(
                f"{threading.current_thread().name}-done with all api search, current page:{current_page} total page:{total_page}, time:{datetime.datetime.now().strftime(time_format)} "
            )

    def start_search_use_api(self, url):
        print("begin to execute search url:{}".format(url))
        headers = {"Connection": "Close"}
        resp = httpClient.http_retry_executor(url, headers=headers)
        if resp is None:
            print("response is none, url:{}".format(url))
            return False
        elif resp.status_code != 200:
            print("url:{},status code:{}".format(url, resp.status_code))
            return False

        print("begin to analyse response body.")

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
            pic.colors = ",".join(p.get("colors"))
            pic.tags = ",".join([])
            pic.created_time = p.get("created_at")
            pic.create_at = datetime.datetime.now().strftime(time_format)
            pic.update_at = datetime.datetime.now().strftime(time_format)
            pics.append(pic)
        else:
            sqliteManager.batch_insert_img(pics)

        return meta

    def start_download_pic(self, start=0, max_count=10000,
                           category=CommonConstant.category_type[2], purity=CommonConstant.purity_type[2]):
        headers = {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/86.0.4240.198 Safari/537.36",
            "referer": CommonConstant.wall_haven_url,
        }

        path = f'{CommonConstant.pic_output_path}/{category}'

        # check dir
        if not os.path.exists(path):
            os.mkdir(path)

        limit = 500
        offset = start
        while True:
            if offset >= max_count:
                print("done all task {0}".format(offset))
                break

            val = sqliteManager.select_images(limit=limit, offset=offset, category=category, purity=purity)
            offset += limit
            if val is None or len(val) == 0:
                break
            else:
                print(
                    "{}-current offset: {}".format(
                        threading.current_thread().name, offset
                    )
                )
                for pic in val:
                    pic_name = ""
                    pos = pic[12].rfind("/")
                    if pos != -1:
                        pic_name = pic[12][pos + 1:]

                    if len(pic_name) == 0:
                        print('picture name is invalid')
                        continue
                    full_name = f"{path}/{pic_name.split('-')[1]}"
                    if f"{pic_name}" in historyImgList or os.path.exists(
                            full_name
                    ):
                        print(f"file id:{pic[0]} has exist.")
                        continue
                    else:
                        print(
                            "{}-begin to download,id:{},name:{},time:{},url:{}".format(
                                threading.current_thread().name,
                                pic[0],
                                full_name,
                                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                                pic[12],
                            )
                        )
                        response = httpClient.http_retry_executor(pic[12], headers)
                        print(
                            "{0}-begin to write,id:{1}, time:{2},path:{3}".format(
                                threading.current_thread().name,
                                pic[0],
                                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                                full_name,
                            )
                        )
                        if response is None:
                            continue

                        with open(full_name, "wb") as f:
                            f.write(response.content)
                        print(
                            "{}-end to write,id:{},time:{},path:{}".format(
                                threading.current_thread().name,
                                pic[0],
                                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                                full_name,
                            )
                        )
