# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import time

import requests

from src.common.proxy_config import ProxyConstant


class HttpClient:

    @classmethod
    def http_retry_executor(cls, url, headers: dict):
        retry = False
        for num in range(0, 5):
            if retry:
                print("retry url:{} for {} time".format(url, num))
            try:
                if ProxyConstant.proxySwitch:
                    return requests.get(url, proxies=ProxyConstant.proxies, verify=True, timeout=300, headers=headers)
                else:
                    return requests.get(url, verify=True, timeout=300)
            except Exception as err:
                print(r"http request failed, retry url:{url}")
                print(err)

                time.sleep(5)

                retry = True
                if num == 4:
                    print("failed at last, please try by hands")
                    return None
