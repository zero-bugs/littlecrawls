# !/usr/bin/python3
# -*- coding: UTF-8 -*-
from src.api_service import ImgServiceApis
from src.page_service import ImgServicePage

if __name__ == "__main__":
    print('begin to work.')
    api_service = ImgServiceApis()
    api_service.scrawl_img_use_api_all()
    print('end work..')

    # pageService=ImgServicePage()
    # pageService.start_search_use_page('https://wallhaven.cc/search?categories=111&purity=001&topRange=1M&sorting=toplist&order=desc')