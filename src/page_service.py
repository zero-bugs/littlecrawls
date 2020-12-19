# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import datetime

from src.common.common_config import CommonConstant
from src.utils.http_utils import httpClient
from bs4 import BeautifulSoup


class ImgServicePage:
    def __init__(self):
        pass

    def start_search_use_page(self, url, page=1):
        if page > 1:
            url += '&page={}'.format(page)
        headers = {
            'user-agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36 ',
            'origin': "{}".format(CommonConstant.wall_haven_url),
            'accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
        }

        resp = httpClient.http_retry_executor(url, headers, useCookie=True)
        if resp.status_code != 200:
            print("http request exception, code:{}, url:{}".format(resp.status_code, url))

        soup = BeautifulSoup(resp.content, 'html.parser')
        img_tb_all = soup.select('#thumbs > section:nth-child(1) > ul > li')
        for tb in img_tb_all:
            print(tb)
            print(tb.contents[0].attrs)



    def start_search_toplist_pic(self):
        self.start_search_use_page(
            'https://wallhaven.cc/search?categories=111&purity=011&topRange=1M&sorting=toplist&order=desc')
