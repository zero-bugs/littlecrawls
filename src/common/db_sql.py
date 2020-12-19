# !/usr/bin/python3
# -*- coding: UTF-8 -*-


create_img_table = (
    "create table if not exists img_table(id text primary key not null,"
    "url text, "
    "views integer, "
    "favorites integer, "
    "source text,"
    "purity text,"
    "category text,"
    "dimension_x integer,"
    "dimension_y integer,"
    "ratio text,"
    "file_size integer,"
    "file_type text,"
    "path text,"
    "colors text,"
    "tags text,"
    "created_time integer, "
    "create_at integer,"
    "update_at integer)"
)

insert_img_sql = (
    "insert or ignore into img_table(id,"
    "url,"
    "views,"
    "favorites,"
    "source,"
    "purity,"
    "category,"
    "dimension_x,"
    "dimension_y,"
    "ratio,"
    "file_size,"
    "file_type,"
    "path,"
    "colors,"
    "tags,"
    "created_time,"
    "create_at,"
    "update_at) "
    "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
)

select_img_sql = (
    "select * from img_table limit ? offset ? "
)

create_para_table = (
    "create table if not exists common_info("
    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "key TEXT,"
    "value TEXT,"
    "description TEXT,"
    "create_at TEXT,"
    "update_at TEXT)"
)

insert_common_sql = (
    "insert or ignore into common_info("
    "key,"
    "value,"
    "description,"
    "create_at,"
    "update_at)"
    "values (?,?,?,?,?)"
)

select_common_sql = (
    "select * from common_info where id = ? or key= ?"
)

del_common_sql = (
    "delete from common_info where id = ? or key = ?"
)