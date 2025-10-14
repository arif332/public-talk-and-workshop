**Table of Content:**
- [1. Kubernetes Cheat Sheet](#1-kubernetes-cheat-sheet)
  - [1.1. Vim profile setup](#11-vim-profile-setup)
  - [1.2. Kubectl autocomplete](#12-kubectl-autocomplete)
  - [1.3. Environment variable setup](#13-environment-variable-setup)
  - [1.4. Kubectl context and configuration](#14-kubectl-context-and-configuration)
- [2. Kubernetes Imperative Command](#2-kubernetes-imperative-command)
  - [2.1. Create a busybox pod for testing](#21-create-a-busybox-pod-for-testing)
  - [2.2. Create a deployment and expose service](#22-create-a-deployment-and-expose-service)
  - [2.3. Activity on deployment](#23-activity-on-deployment)
  - [2.4. Add labels](#24-add-labels)
  - [2.5. Create Ingress Resource](#25-create-ingress-resource)
  - [2.6. Get events](#26-get-events)
  - [2.7. DNS record check](#27-dns-record-check)
  - [2.8. Fort Forward to Service/Pod](#28-fort-forward-to-servicepod)
  - [2.9. Check SSL Certificate](#29-check-ssl-certificate)
  - [2.10. Create SSL Certificate](#210-create-ssl-certificate)
- [3. References](#3-references)



# 1. Kubernetes Cheat Sheet


## 1.1. Vim profile setup

```bash
cat <<EOF>~/.vimrc
set ts=2 sw=2 sts=2 et ai number colorcolumn=3,5,7,9
syntax on
colorscheme ron
EOF
# other options - paste, nopaste
# visual line(shift+v) / visual block(ctl+v) mode will help a lot to edit yaml config comfortably
```

## 1.2. Kubectl autocomplete

```bash
# vim ~/.bashrc # add autocomplete permanently to your bash shell.

source <(kubectl completion bash)
complete -F __start_kubectl k

```

## 1.3. Environment variable setup

```bash
cat <<EOF>kalias.sh
alias k="kubectl"
alias kgn="kubectl get node" 
alias aa='kubectl get all,sa,ep,sc,pv,pvc,cm,netpol'
alias kcc='kubectl config get-contexts'

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace)
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

export do="--dry-run=client -o yaml"
EOF
```

```bash
source kalias.sh
```

## 1.4. Kubectl context and configuration

```bash
kubectl config view # Show Merged kubeconfig settings.

# use multiple kubeconfig files at the same time and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 

kubectl config view

# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts 
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce

kubectl config unset users.foo                       # delete user foo

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace) 
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
```



# 2. Kubernetes Imperative Command

## 2.1. Create a busybox pod for testing
```bash
# buysbox pod with curl command
k run client --image=radial/busyboxplus:curl -- /bin/sh -c "sleep 3600"
# busybox pod with curl command and log write 
k run client --image=radial/busyboxplus:curl --command -- /bin/sh -c "while true; do echo hi; sleep 10; done"

#busybox with sh/bash
k exec -it client -- sh
k exec client -- curl ip

k run -it busybox --image=busybox:1.28 -- sh  # Run pod as interactive shell
k attach busybox -c busybox -i -t

# more debugging
k exec client -- nslookup client
```


## 2.2. Create a deployment and expose service
```bash
k create deployment nginx-deploy --image=nginx -r 3

#port=service port, target-port=pod port,
k expose deployment nginx-deploy --port=80 --target-port=8080 --name nginx-svc
```

## 2.3. Activity on deployment
```bash
# change image version and record will keep history of the given command
k set image deploy nginx-deploy nginx=nginx:1.16.1 --record

# edit deployment 
k edit deploy nginx-deployment

# make zero replication 
k scale deploy nginx-deploy --replicas=0 

# restart a deployment
k rollout restart deploy nginx-deploy

# check update history, .spec.revisionHistoryLimit (default is 10)
k rollout history deploy nginx-deploy

# roolout status
k rollout status deploy apparmor 

#roll-back
k rollout undo deploy apparmor 
```


## 2.4. Add labels
```bash
k label ns nptest project=test
k label pods client role=client
```

## 2.5. Create Ingress Resource
```bash
# exact match with a tls certificate, need to know svc name and port of svc
k create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"

# any match with a tls, need to know svc name and port of svc
k create ingress simple --rule="foo.com/*=svc1:8080,tls=my-cert"
```

## 2.6. Get events

```bash
k get ev -w

# get event by timestamp
k -n ns get events --sort-by='{.metadata.creationTimestamp}'
```

## 2.7. DNS record check
```bash
k apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
k exec -it dnsutils -- nslookup kubernetes.default
k exec client -- cat /etc/resolv.conf
k exec client -- nslookup pod-name

#dns sever check
k logs -n kube-system -l k8s-app=kube-dns
```


## 2.8. Fort Forward to Service/Pod

```bash
# listen on 0.0.0.0:9021 which allow to connect from external host
k port-forward controlcenter-0 9021:9021 --address='0.0.0.0'
```

## 2.9. Check SSL Certificate
```bash
# check certificate information
openssl x509 -in cert.pem -text
```

## 2.10. Create SSL Certificate
```bash
openssl help req
# generate cert and key which can be used in tls secret
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -new -nodes -subj "/CN=test.com"
```


# 3. References
- https://kubernetes.io/docs/reference/kubectl/quick-reference/
- https://github.com/arif332/kubernetes-tutorial/blob/main/k8s-cli.md