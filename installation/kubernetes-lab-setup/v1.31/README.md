**Table of Contents:**
- [1. Kubernetes Home Lab Cluster Using Kubernetes v1.31](#1-kubernetes-home-lab-cluster-using-kubernetes-v131)
  - [1.1. OS Level Config](#11-os-level-config)
  - [1.2. Kubernetes Cluster Installation : Step by Step Procedure](#12-kubernetes-cluster-installation--step-by-step-procedure)
    - [1.2.1. Control-plane node](#121-control-plane-node)
    - [1.2.2. Worker node](#122-worker-node)
  - [1.3. Kubernetes Cluster Installation Using Script](#13-kubernetes-cluster-installation-using-script)
    - [1.3.1. Control-plane node](#131-control-plane-node)
    - [1.3.2. Worker node](#132-worker-node)
  - [1.4. Reset Kubernetes Cluster](#14-reset-kubernetes-cluster)
- [2. References](#2-references)


# 1. Kubernetes Home Lab Cluster Using Kubernetes v1.31

The home lab will be set up using [Ubuntu 22.04 LTS](https://ubuntu.com/server). The document assumes that you have already installed the server with the required OS version. 


## 1.1. OS Level Config

We are going to use three VM nodes for the Kubernetes cluster. Each VM node should have a unique IP address in the network. 

An example `netplan` file at `/etc/netplan/50-cloud-init.yaml` has a first NAT interface and a second host-only interface with a fixed IP address. First, check the number of interfaces in your VMs and modify the config file accordingly. 

```bash
# /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.56.102/24  
      # gateway4: 192.168.56.1  
```


## 1.2. Kubernetes Cluster Installation : Step by Step Procedure 

In this section, we will setup/install a kubernetes cluster.  

### 1.2.1. Control-plane node

Login kubernetes node as a root and do the following task. 


Export follwoing two variables in your current terminal:
```bash
KUBERNETES_VERSION=v1.31
CRIO_VERSION=v1.31
```

Install the dependencies for adding repositories
```bash
apt-get update
apt-get install -y software-properties-common curl
```

Add the Kubernetes repository:
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
```


Add the CRI-O repository:
```bash
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list
```

Install the packages:
```bash
apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl
```

Start CRI-O:
```bash
systemctl start crio.service
```

Disable swap space:
```bash
# make swap off, for permant change edit file /etc/fstab
swapoff -a
vim /etc/fstab
```

Change network config:
```bash
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1
```

Or, to change network setting permanently:
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward
```


Bootstrap a cluster:
If you have a single network interface, the Kubernetes cluster can be initiated with the following command.  
```bash
kubeadm init
```

If the VM has multiple network interfaces, you may specify each interface's IP address and port number when initializing the Kubernetes cluster.     
```bash
kubeadm init --control-plane-endpoint 192.168.56.101:6443
```



### 1.2.2. Worker node

Login kubernetes node as a root and do the following task:


Export follwoing two variables in your current terminal:
```bash
KUBERNETES_VERSION=v1.31
CRIO_VERSION=v1.31
```

Install the dependencies for adding repositories
```bash
apt-get update
apt-get install -y software-properties-common curl
```

Add the Kubernetes repository:
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
```


Add the CRI-O repository:
```bash
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list
```

Install the packages:
```bash
apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl
```

Start CRI-O:
```bash
systemctl start crio.service
```

Disable swap space:
```bash
# make swap off, for permant change edit file /etc/fstab
swapoff -a
vim /etc/fstab
```

Change network config:
```bash
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1
```

Or, to change network setting permanently:
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward
```

Now, run below command from control-plane node and you will get joining command to execute from worker node.
```bash
kubeadm token create --print-join-command --ttl 0
```


Now, execute joining command (will be generated in previous command, token will expire after 24 hour) in the worker node:
```bash
kubeadm join 172.31.47.143:6443 --token bqrhd2.aocpuq2c5ug81fmo --discovery-token-ca-cert-hash sha256:5b2ad604804e2edc5367b35314ef190af8389d6a509f99a79ea7b35463a6727c 
```

Once joing command is successful, then check cluster status.
```bash
kubectl get node
```


Ref:
- https://github.com/cri-o/packaging/blob/main/README.md#available-streams


## 1.3. Kubernetes Cluster Installation Using Script

Setup sudo priviledge so that it dont ask password:
```bash
root@dc78def55f1c:~# cat /etc/sudoers.d/clouduser 
cloud_user ALL=(ALL) NOPASSWD:ALL
```

Login and move to root prompt:
```bash
sudo -i
```

### 1.3.1. Control-plane node

Install Master node software:
```bash
sudo ./cka-master-install.sh
```

Create cluster:
```bash
sudo ./cka-create-cluster.sh
```

Logs:
```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.47.143:6443 --token <value withheld> \
        --discovery-token-ca-cert-hash sha256:5b2ad604804e2edc5367b35314ef190af8389d6a509f99a79ea7b35463a6727c 

### COMMAND TO ADD A WORKER NODE ###
kubeadm join 172.31.47.143:6443 --token bqrhd2.aocpuq2c5ug81fmo --discovery-token-ca-cert-hash sha256:5b2ad604804e2edc5367b35314ef190af8389d6a509f99a79ea7b35463a6727c 
```

Check node firewall setting before joining to cluster:
```bash
ufw disable
```


### 1.3.2. Worker node

Install Master node software:
```bash
sudo ./cka-worker-install.sh
```

To join kubernetes cluster, run below command from control-plane node and will get a joining command that require to execute in the worker node:
```bash
kubeadm token create --print-join-command --ttl 0
```

Now, execute joining command (will be generated in previous command, token will expire after 24 hour) in the worker node:
```bash
kubeadm join 172.31.47.143:6443 --token bqrhd2.aocpuq2c5ug81fmo --discovery-token-ca-cert-hash sha256:5b2ad604804e2edc5367b35314ef190af8389d6a509f99a79ea7b35463a6727c 
```


Once joing command is successful, then check cluster status.
```bash
kubectl get node
```

## 1.4. Reset Kubernetes Cluster

If you want to reset current kubernetes cluster, then execute below command from both control-plane and worker nodes. Again, you have to follow previous steps to initialize kubernetes cluster:
```bash
kubeadm reset -f
rm /root/.kube/config
```

if you want to reset a worker node, then execute below command form that specific worker node:
```bash
kubeadm reset -f
rm /root/.kube/config
```



# 2. References
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://github.com/cri-o/packaging/blob/main/README.md#available-streams
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/