#!/bin/bash
#
# 安装所需的软件包
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 设置 stable 镜像仓库
sudo yum-config-manager \
     --add-repo \
     https://download.docker.com/linux/centos/docker-ce.repo

# 更新 yum 软件包索引
sudo yum makecache fast
# 安装最新版本的 Docker CE
# sudo yum install docker-ce

# 查看docker版本
yum list docker-ce.x86_64  --showduplicates | sort -r

# 请选择docker版本 sudo yum install -y docker-ce-17.12.1.ce-1.el7.centos
echo "确定docker版本后，运行命令：sudo yum install -y docker-ce-<VERSION> \n"
echo "例如 sudo yum install -y docker-ce-17.12.1.ce-1.el7.centos \n"

echo "启动docker命令： sudo systemctl start docker \n"

echo "验证docker是正确安装： sudo docker run hello-world \n"


# 参考资料  https://docs.docker-cn.com/engine/installation/linux/docker-ce/centos/#%E4%BD%BF%E7%94%A8%E9%95%9C%E5%83%8F%E4%BB%93%E5%BA%93%E8%BF%9B%E8%A1%8C%E5%AE%89%E8%A3%85
