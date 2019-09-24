#!/bin/bash
#
DB_USER=root
DB_PASS=123456
DB_NAME=test_mysql5

# 创建数据库 并导入已有数据库
function createDatabase() {
    mysql -u $DB_USER -p$DB_PASS << EOF 2> /dev/null
CREATE DATABASE $DB_NAME
USE $DB_NAME
source /www/backup/ss-message_20190920_181114.sql
EOF
}

createDatabase


### 参考资料
# - https://blog.csdn.net/wyl9527/article/details/72655277