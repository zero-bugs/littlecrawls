# !/usr/bin/python3
# -*- coding: UTF-8 -*-
from src.api_service import ImgServiceApis

if __name__ == "__main__":
    print('begin to work.')
    imgService = ImgServiceApis()
    imgService.scrawPicUseApiAll()
    print('end work..')