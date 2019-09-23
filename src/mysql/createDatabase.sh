#!/bin/bash
#
DB_USER=root
DB_PASS=123456
DB_NAME=test_mysql5

# 创建数据库
function createDatabase() {
    mysql -u $DB_USER -p$DB_PASS << EOF 2> /dev/null
CREATE DATABASE $DB_NAME
EOF
}

createDatabase
