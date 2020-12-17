# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import json
import time

import requests

from src.common.proxy_config import ProxyConstant


class HttpClient:
    @staticmethod
    def http_retry_executor(url, headers):
        retry = False
        for num in range(0, 5):
            if retry:
                print("retry url:{} for {} time".format(url, num))
            try:
                if ProxyConstant.proxySwitch:
                    return requests.get(url, verify=True, timeout=120, proxies=ProxyConstant.proxies, headers=headers)
                else:
                    return requests.get(url, verify=True, timeout=120, headers=headers)
            except Exception as err:
                print("http request failed, retry url:{}".format(url))
                print(err)

            time.sleep(5)

            retry = True
            if num == 4:
                print("failed at last, please try by hands")
                return None
