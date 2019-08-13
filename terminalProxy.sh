#!/bin/sh
#
# Mac下用brew安装`privoxy`
# 将这个shell文件在启动shell中 `source` 一下，例如，在`~/.profile`中，加上`source terminalProxy.sh`
# 使用时，直接使用命令行`noproxy`取消代理，或者`setproxy`进行设置代理
#
# http proxy
function noproxy()
{
        unset http_proxy;unset https_proxy;
        echo -e "已关闭代理"
}

function setproxy()
{
        export no_proxy="localhost,127.0.0.1"
        export http_proxy='http://127.0.0.1:8118'
        export https_proxy=$http_proxy
        echo -e "已开启代理"
}

## 参考资料
# * http://dongdongdong.me/2018/01/31/OS/Installation/Ubuntu/ladder/
