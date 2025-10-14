#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/
# 04-10-2024
# CKA Training Cluster Installation
# 


### Change Basic Setting

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward

# disable swap
swapoff -a
echo "/swapfile none swap sw 0 0" >> /etc/fstab
swapon --show


############################## Install CRI ##############################
CRIO_VERSION=v1.31

mkdir -p /etc/apt/keyrings/

apt-get update
apt-get install -y software-properties-common curl
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" | \
    tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o
systemctl start crio.service





#################### install kubelete, kubeadm and kubectl #################

KUBERNETES_VERSION=1.31

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gp
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list


# curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
#     gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" |
#     tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet





# # reset old cluster
# rm /root/.kube/config
# kubeadm reset -f

# # create new cluster
# kubeadm init --config kubeadm-config.yaml --upload-certs --ignore-preflight-errors=Swap --skip-token-print

# mkdir -p ~/.kube
# sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config

# echo
# echo "### COMMAND TO ADD A WORKER NODE ###"
# kubeadm token create --print-join-command --ttl 0



