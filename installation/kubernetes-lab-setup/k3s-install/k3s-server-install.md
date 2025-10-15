**Table of Contents:**
- [1. K3s Server Installation](#1-k3s-server-installation)
  - [1.1. Install at Default Location](#11-install-at-default-location)
  - [1.2. HA Cluster](#12-ha-cluster)
- [2. References](#2-references)


# 1. K3s Server Installation


## 1.1. Install at Default Location

Remove `noexec` for `/var` at file `/etc/fstab` and restarted node to install k3s at location `/var/lib/rancher/k3s`.

```bash
# check noexec permission at /var/lib/rancher/k3s/data
[appadmin@xxxxx ~]$ cat /etc/fstab |grep /var
/dev/mapper/root_vg-var /var                    xfs     defaults,rw,nosuid,nodev,noexec,relatime        0 0
```


Install Latex K3S Server:
```bash
# curl -sfL https://get.k3s.io | sh -
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -

# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--data-dir /app/var/lib/rancher/k3s/data/" sh -
```

Now k3s server process started:
```bash
sudo systemctl status k3s
```

Restart command if require:
```bash
# sudo systemctl daemon-reload
# sudo systemctl restart k3s
```


```bash
export PATH=$PATH:/usr/local/bin
```

Alias for work:
```bash
alias k="kubectl"
source <(kubectl completion bash)
complete -F __start_kubectl k
# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace)
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
alias kcc='kubectl config get-contexts'
```


```bash
export KUBECONFIG=/app/var/lib/rancher/k3s/data/server/cred/admin.kubeconfig 
```

```bash
/etc/rancher/k3s/k3s.yaml
[root@gzopentelemetry01 k3s]# chmod +r k3s.yaml 

xxxxxx$ kubectl get node
NAME                               STATUS   ROLES                  AGE   VERSION
xxxxxx   Ready    control-plane,master   35h   v1.31.6+k3s1
```



```bash
export CRICTL_CONFIG=/app/var/lib/rancher/k3s/data/agent/etc/crictl.yaml
```


Command to check status:
```bash
# kubectl get node

# kubectl get pod -A

# ip -br a
```


## 1.2. HA Cluster

Install K3s on the First Master Node (Leader):

```bash
curl -sfL https://get.k3s.io | sh -s - server --cluster-init
```

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
hostname -I | awk '{print $1}'
```

Join Additional Control Plane Nodes:
```bash
curl -sfL https://get.k3s.io | K3S_URL="https://<FIRST_MASTER_IP>:6443" K3S_TOKEN="<TOKEN>" sh -
```


```bash
kubectl get nodes
```


Join Worker Nodes:
```bash
curl -sfL https://get.k3s.io | K3S_URL="https://<FIRST_MASTER_IP>:6443" K3S_TOKEN="<TOKEN>" sh -s - agent
```


# 2. References
- https://k3s.io/