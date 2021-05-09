# !/usr/bin/python3
# -*- coding: UTF-8 -*-
import os

from src.common.common_config import CommonConstant


def get_file_list(dir_name):
    file_list = list()
    for home, dirs, filenames in os.walk(dir_name):
        print(f"home:{home}, dirs:{dirs}")
        for pt in dirs:
            print(pt)

        for filename in filenames:
            filename = filename.strip()
            if not filename.startswith('wallhaven-'):
                filename = f'wallhaven-{filename}'
            file_list.append(filename)
    return file_list


if __name__ == "__main__":
    path = CommonConstant.pic_output_path
    files = get_file_list(path)
    with open('file_list.tmp', mode='w') as f:
        f.writelines(os.linesep.join(files))
