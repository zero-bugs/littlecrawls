# !/usr/bin/python3
# -*- coding: UTF-8 -*-
from src.api_service import ImgServiceApis
from src.page_service import ImgServicePage

if __name__ == "__main__":
    # print('begin to work.')
    # imgService = ImgServiceApis()
    # imgService.scrawPicUseApiAll()
    # print('end work..')

    pageService=ImgServicePage()
    pageService.start_search_use_page('https://wallhaven.cc/search?categories=111&purity=010&topRange=1M&sorting=toplist&order=desc')