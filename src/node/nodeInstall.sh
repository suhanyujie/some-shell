#!/bin/bash
#
# linux环境下 安装node
version="10.15.3"
wget https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz
tar xvf node-v${version}-linux-x64.tar.xz
cd node-v${version}-linux-x64
currentPath=`pwd`
ln -s ${currentPath}/bin/node  /usr/bin/node
ln -s ${currentPath}/bin/npm /usr/bin/npm
ln -s ${currentPath}/bin/npx /usr/bin/npx
echo "安装完成\n"
