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

    def start_to_download_latest_imgs(
            self, current_page=1, total_page=1000, start_time=None,
            category=CommonConstant.category_type_db[2],
            purity=CommonConstant.purity_type_db[2]
    ):
        # 初始化初始时间
        if start_time is None:
            val = sqliteManager.select_images(limit=1, offset=0, category=category,
                                              purity=purity)
            if val is None or len(val) == 0:
                print(f"cannot obtain start time, task stop")
                return
            start_time = datetime.datetime.strptime(val[0][15], time_format)
        else:
            start_time = datetime.datetime.strptime(start_time, time_format)

        print(f"start time is {start_time}")

        total_imgs = 0
        current_page = current_page
        total_page = total_page
        while current_page <= total_page:
            print(
                f"{threading.current_thread().name}-begin to request, current page:{current_page}, total page:{total_page}"
            )

            url = "{}/api/v1/search?apikey={}&categories={}&purity={}&page={}".format(
                CommonConstant.wall_haven_url,
                CommonConstant.api_key,
                CommonConstant.category_map[category],
                CommonConstant.purity_map[purity],
                current_page,
            )

            resp = httpClient.http_retry_executor(url, headers={"Connection": "Close"})
            if resp is None:
                print("response is none, url:{}".format(url))
                return None
            elif resp.status_code != 200:
                print("url:{},status code:{}".format(url, resp.status_code))
                return None

            pics = list()
            respJson = json.loads(resp.content)

            meta = SearchMeta()
            meta.current_page = respJson.get("meta").get("current_page")
            meta.last_page = respJson.get("meta").get("last_page")
            meta.per_page = respJson.get("meta").get("per_page")
            meta.total = respJson.get("meta").get("total")
            meta.query = respJson.get("meta").get("query")
            meta.seed = respJson.get("meta").get("seed")

            item_nums = 0
            item_nums_no = 0
            pic_create_time = None
            for p in respJson.get("data"):
                item_nums_no += 1
                pic = self.construct_img(p)
                pic_create_time = datetime.datetime.strptime(
                    pic.created_time, time_format
                )
                if pic_create_time - start_time > datetime.timedelta(seconds=0):
                    pics.append(pic)
                else:
                    item_nums += 1

            print("item_nums:{}, item_nums_no:{},pic_create_time:{}, start_time:{}".format(
                item_nums, item_nums_no, pic_create_time, start_time
            ))

            if item_nums == item_nums_no:
                print(f"task done.")
                break

            for pic in pics:
                path = f"{CommonConstant.pic_output_path}/{pic.category}/{pic.purity}"
                if not os.path.exists(path):
                    os.makedirs(path, exist_ok=True)

                # 检查是否存在
                full_name = f"{path}/{pic.id}{pic.path[pic.path.rfind('.'):]}"

                this_pic = sqliteManager.select_images_with_id(pic.id)

                if this_pic is None or len(this_pic) == 0:
                    self.download_single_pic(
                        full_name, {"Connection": "Close"}, pic.id, pic.path, create_time=pic.created_time
                    )
                    # 插入数据库
                    sqliteManager.insert_img(pic)
                    total_imgs += 1
                else:
                    print(f"pic {pic.id} exist, continue..")
            print(
                f"{threading.current_thread().name}-end with scrawl, current page:{current_page}, total page:{total_page}"
            )
            time.sleep(2)
            current_page += 1
            if meta is None:
                continue
            total_page = meta.last_page
        print(
            f"{threading.current_thread().name}-done with all api search, current page:{current_page} total page:{total_page}, time:{datetime.datetime.now().strftime(time_format)}, total image:{total_imgs}"
        )

    def construct_img(self, p):
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
        return pic

    def scrawl_img_use_api_category(
            self,
            current_page=1,
            total_page=10000,
            category=CommonConstant.category_type_db[2],
            purity=CommonConstant.purity_type_db[2],
    ):
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

            time.sleep(2)

            current_page += 1

            if meta is None:
                continue

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
            return None
        elif resp.status_code != 200:
            print("url:{},status code:{}".format(url, resp.status_code))
            return None

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
            pic = self.construct_img(p)
            pics.append(pic)
        else:
            sqliteManager.batch_insert_img(pics)

        return meta

    def start_download_pic(
            self,
            start=0,
            max_count=10000,
            category=CommonConstant.category_type_db[2],
            purity=CommonConstant.purity_type_db[2],
    ):
        headers = {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/86.0.4240.198 Safari/537.36",
            "referer": CommonConstant.wall_haven_url,
        }

        path = f"{CommonConstant.pic_output_path}/{category}/{purity}"

        # check dir
        if not os.path.exists(path):
            os.makedirs(path, exist_ok=True)

        limit = 100
        offset = start
        while True:
            if offset >= max_count:
                print("done all task {0}".format(offset))
                break

            val = sqliteManager.select_images(
                limit=limit, offset=offset, category=category, purity=purity
            )
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
                        print("picture name is invalid")
                        continue
                    full_name = f"{path}/{pic_name.split('-')[1]}"
                    if f"{pic_name}" in historyImgList or os.path.exists(full_name):
                        print(f"file id:{pic[0]} has exist.")
                        continue
                    else:
                        self.download_single_pic(full_name, headers, pic[0], pic[12])

                        time.sleep(1)

    def download_single_pic(self, full_name, headers, pic_id, pic_path,
                            create_time=time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime())):
        print(
            "{}-begin to download,id:{},name:{},create_time:{}, time:{},url:{}".format(
                threading.current_thread().name,
                pic_id,
                full_name,
                create_time,
                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                pic_path,
            )
        )
        response = httpClient.http_retry_executor(pic_path, headers)
        print(
            "{0}-begin to write,id:{1}, time:{2},path:{3}".format(
                threading.current_thread().name,
                pic_id,
                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                full_name,
            )
        )
        if response is None or response.status_code >= 300:
            print(
                "{0}-download pic exception,id:{1}, time:{2},path:{3}".format(
                    threading.current_thread().name,
                    pic_id,
                    time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                    full_name,
                )
            )
            return

        with open(full_name, "wb") as f:
            f.write(response.content)
        print(
            "{}-end to write,id:{},time:{},path:{}".format(
                threading.current_thread().name,
                pic_id,
                time.strftime("%Y-%m-%d-%H_%M_%S", time.localtime()),
                full_name,
            )
        )
