#!/bin/sh

# 04-10-2024
# CKA Training Cluster Installation

# reset old cluster
rm /root/.kube/config
kubeadm reset -f

# create new cluster
kubeadm init --config kubeadm-config-v131.yaml --upload-certs --ignore-preflight-errors=Swap --skip-token-print

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config

echo
echo "### COMMAND TO ADD A WORKER NODE ###"
kubeadm token create --print-join-command --ttl 0

