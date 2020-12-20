# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import datetime

from src.common.common_config import CommonConstant
from src.common.constant import time_format
from src.db.sq_connection import sqliteManager
from src.model.img_attrib import WallPicAttr
from src.utils.http_utils import httpClient
from bs4 import BeautifulSoup


class ImgServicePage:
    def __init__(self):
        pass

    def start_search_use_page(self, url, page=1):
        if page > 1:
            url += "&page={}".format(page)
        headers = {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36 ",
            "origin": "{}".format(CommonConstant.wall_haven_url),
            "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        }

        resp = httpClient.http_retry_executor(url, headers, useCookie=True)
        if resp.status_code != 200:
            print(
                "http request exception, code:{}, url:{}".format(resp.status_code, url)
            )

        soup = BeautifulSoup(resp.content, "html.parser")
        img_tb_all = soup.select("#thumbs > section:nth-child(1) > ul > li")
        pics = list()
        for tb in img_tb_all:
            print(tb)
            pic = WallPicAttr()
            figure_node = tb.next
            pic.id = figure_node.attrs["data-wallpaper-id"]
            pic.category = (figure_node.attrs["class"][3]).removeprefix("thumb-")
            pic.purity = (figure_node.attrs["class"][2]).removeprefix("thumb-")

            img_node = figure_node.select_one(".lazyload")
            preview_node = figure_node.select_one(".preview")
            solution_node = figure_node.select_one("div > span")
            favourite_node = figure_node.select_one(
                "div > a.jsAnchor.overlay-anchor.wall-favs"
            )

            if img_node:
                pic.source = img_node.attrs["src"]
                pic.file_type = f"image/{img_node.attrs['data-src'].split('.')[-1]}"
            if preview_node:
                pic.path = preview_node.attrs["href"]

            if solution_node and favourite_node:
                solution = solution_node.next.split("x")
                pic.dimension_x = int(solution[0].strip())
                pic.dimension_y = int(solution[1].strip())
                pic.favorites = int(favourite_node.next.strip())
                pic.url = favourite_node.attrs["data-href"]
            pic.create_at = str(datetime.datetime.now().strftime(time_format))
            pic.update_at = str(datetime.datetime.now().strftime(time_format))
            pics.append(pic)
            print(pic)
        else:
            print(f"pics len:{len(pics)}")
            for p in pics:
                print(p.path)
            # sqliteManager.batch_insert_img(pics)

    def start_search_toplist_pic(self):
        self.start_search_use_page(
            "https://wallhaven.cc/search?categories=111&purity=011&topRange=1M&sorting=toplist&order=desc"
        )
