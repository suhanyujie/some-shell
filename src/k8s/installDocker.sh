#!/usr/bin/env bash
#
# 此 shell 根据 k8s 安装教程编写 https://kuboard.cn/install/install-k8s.html

function installDocker()
{
    # 卸载旧版本
    sudo yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine

    # 设置 yum repository
    sudo yum install -y yum-utils device-mapper-persistent-data  lvm2
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    # 安装并启动 docker
    sudo yum install -y docker-ce-18.09.7 docker-ce-cli-18.09.7 containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker

    # 检查 docker 版本
    docker version
    echo "installDocker 步骤完成-----------------------------------------"
}

function installUtils()
{
    yum install -y nfs-utils
    echo "installUtils 步骤完成-----------------------------------------"
}

function installKube()
{
    # 关闭 防火墙
    systemctl stop firewalld
    systemctl disable firewalld
    setenforce 0
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
    # 关闭 swap
    swapoff -a
    yes | cp /etc/fstab /etc/fstab_bak
    cat /etc/fstab_bak |grep -v swap > /etc/fstab
    # 修改 /etc/sysctl.conf
    # 如果有配置，则修改
    sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
    sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
    sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
    # 可能没有，追加
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
    echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
    # 执行命令以应用
    sysctl -p
    # 配置K8S的yum源
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
    # 安装kubelet、kubeadm、kubectl
    yum install -y kubelet-1.15.2 kubeadm-1.15.2 kubectl-1.15.2

    # 修改docker Cgroup Driver为systemd
    sed -i "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service

    # 重启 docker，并启动 kubelet
    systemctl daemon-reload
    systemctl restart docker
    systemctl enable kubelet && systemctl start kubelet
    echo "installKube 步骤完成-----------------------------------------"
}

installDocker
installUtils
installKube
