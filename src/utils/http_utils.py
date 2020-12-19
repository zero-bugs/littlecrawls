# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import datetime
import json
import time
import uuid

import requests
from bs4 import BeautifulSoup
from requests.utils import dict_from_cookiejar, cookiejar_from_dict

from src.common.common_config import CommonConstant
from src.common.proxy_config import ProxyConstant
from src.db.sq_connection import sqliteManager
from requests.cookies import RequestsCookieJar


class HttpClient:
    def __init__(self):
        self.currentCookie = None
        self.lastUpdateCookieTime = None
        self.lastUpdateUuidTime = None
        self.traceCookie = ["_pk_id.1.01b8", "_pk_ses.1.01b8"]
        self.cookieNamePrefixList = [
            "__cfduid",
            "XSRF-TOKEN",
            "wallhaven_session",
            "remember_web",
        ]

    def http_retry_executor(
        self, url, headers: dict, payload=None, method="get", useCookie=False
    ):
        if payload is None:
            payload = {}
        if headers is None:
            headers = {}

        retry = False
        proxy = ProxyConstant.proxies if ProxyConstant.proxySwitch else None

        # common headers
        headers[
            "user-agent"
        ] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"
        headers["origin"] = "{}".format(CommonConstant.wall_haven_url)
        headers[
            "accept"
        ] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        headers["accept-language"] = "zh-CN,zh;q=0.9"

        cookie_jar = RequestsCookieJar()
        if useCookie and self.currentCookie is not None:
            cookie_jar = self.currentCookie
        elif useCookie and self.currentCookie is None:
            self.login_in()

        for num in range(0, 5):
            if retry:
                print("retry url:{} for {} time".format(url, num))
            try:
                resp = None
                if method == "post":
                    headers["accept-encoding"] = "gzip, deflate, br"
                    # headers['content-type'] = 'application/x-www-form-urlencoded'
                    resp = requests.post(
                        url,
                        data=payload,
                        verify=True,
                        timeout=120,
                        proxies=proxy,
                        headers=headers,
                        cookies=cookie_jar,
                        allow_redirects=False,
                    )
                else:
                    resp = requests.get(
                        url,
                        verify=True,
                        timeout=120,
                        proxies=proxy,
                        headers=headers,
                        cookies=cookie_jar,
                        allow_redirects=False,
                    )
                if resp is not None and resp.status_code < 400:
                    self.updateCookie(resp)
                elif resp is not None:
                    print(
                        "request exception, status code:{}, method:{}, url:{}".format(
                            resp.status_code, method, url
                        )
                    )
                    print("request cookie:{}".format(cookie_jar))
                    print("resp cookie:{}".format(resp.cookies))
                    print("request headers:{}".format(headers))
                    print("response headers:{}".format(resp.headers))
                    print("request payload:{},type:{}".format(payload, type(payload)))

                else:
                    print(
                        "resp is null, cookie:{}, url:{}".format(
                            self.currentCookie, url
                        )
                    )
                return resp
            except Exception as err:
                print("http request failed, retry url:{}".format(url))
                print(err)

            time.sleep(5)

            retry = True
            if num == 4:
                print("failed at last, please try by hands")
                return None

    def login_in(self):
        # check local cookies
        result_set = sqliteManager.select_common_tb(key="cookies")
        local_cookie = ""
        if result_set is not None:
            for entry in result_set:
                if datetime.datetime.now() - datetime.datetime.fromisoformat(
                    entry[4]
                ) > datetime.timedelta(minutes=60):
                    sqliteManager.del_common_tb(index=entry[0])
                    print(f"delete expire cookie:{entry[2]}")
                    continue

                local_cookie = entry[2]

        if len(local_cookie) != 0:
            self.currentCookie = RequestsCookieJar()
            cookiejar_from_dict(json.loads(local_cookie),cookiejar=self.currentCookie)
            print(f"use local cookie:{local_cookie}")
            return

        resp = self.http_retry_executor(
            "{}/login".format(CommonConstant.wall_haven_url), {}
        )
        if resp is None or resp.status_code != 200:
            print("login in error, code:{}".format(resp))
            return None

        soup = BeautifulSoup(resp.text, "html.parser")
        token = soup.select("#login > input[type=hidden]:nth-child(1)")[0]["value"]

        print("obtain _token:{}".format(token))

        resp = self.http_retry_executor(
            "{}/auth/login".format(CommonConstant.wall_haven_url),
            {
                "referer": "{}/login".format(CommonConstant.wall_haven_url),
                "origin": CommonConstant.wall_haven_url,
                "sec-fetch-site": "same-origin",
                "sec-fetch-dest": "document",
                "sec-fetch-mode": "navigate",
                "sec-fetch-user": "?1",
                "upgrade-insecure-requests": "1",
            },
            payload={
                "_token": token,
                "username": CommonConstant.username,
                "password": CommonConstant.password,
            },
            method="post",
            useCookie=True,
        )
        print(
            "login request code:{}, headers:{}".format(resp.status_code, resp.headers)
        )
        if resp.status_code == 302:
            print("get redirect location->{} success".format(resp.headers["location"]))
            if resp.headers["location"] == "{}/user/{}".format(
                CommonConstant.wall_haven_url, CommonConstant.username
            ):
                print("welcome {} to access wallhaven".format(CommonConstant.username))
            else:
                self.clearCookie()
                raise Exception("username or password is wrong")
        else:
            self.clearCookie()
            raise Exception("login in wallhaven failed.")

    def updateCookie(self, resp):
        if resp is None or resp == "":
            return

        self.currentCookie = resp.cookies
        self.updateWipikId(self.currentCookie)

        # 每30分钟插入一次cookie
        if (
            self.lastUpdateCookieTime is None
            or datetime.datetime.now() - self.lastUpdateCookieTime
            > datetime.timedelta(minutes=30)
        ) and self.currentCookie:
            cookie_dict = dict_from_cookiejar(self.currentCookie)
            for key in cookie_dict.keys():
                if self.cookieNamePrefixList[3] in key:
                    sqliteManager.insert_common_tb('cookies', json.dumps(cookie_dict))
                    print('write cookie to db..')
                    self.lastUpdateCookieTime=datetime.datetime.now()
                    break

    def updateWipikId(self, mp: RequestsCookieJar):
        if mp is None:
            return
        if (
            self.lastUpdateUuidTime is None
            or datetime.datetime.now() - self.lastUpdateUuidTime
            > datetime.timedelta(minutes=60)
        ):
            uid = str(
                uuid.uuid5(
                    uuid.NAMESPACE_OID,
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36",
                )
            ).replace("-", "")[0:16]
            curtime = round(time.time())

            mp.set(
                self.traceCookie[0],
                "{}.{}.{}.{}".format(uid, curtime, curtime, curtime),
                domain="wallhaven.cc",
                path="/",
            )
            mp.set(self.traceCookie[1], "1", domain="wallhaven.cc", path="/")

            self.lastUpdateUuidTime = datetime.datetime.now()

    def clearCookie(self):
        sqliteManager.del_common_tb("", "cookies")


httpClient = HttpClient()
