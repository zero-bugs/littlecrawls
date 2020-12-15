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
    "file_size text,"
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
