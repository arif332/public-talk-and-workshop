# Exmaple of NodeSelector 

Example of nodeSelector:
```bash
root@dc78def55f1c:/etc/kubernetes/manifests# k label nodes dc78def55f3c.mylabserver.com disktype=ssd
node/dc78def55f3c.mylabserver.com labeled


root@dc78def55f1c:/etc/kubernetes/manifests# k get node
NAME                           STATUS   ROLES           AGE   VERSION
dc78def55f1c.mylabserver.com   Ready    control-plane   34d   v1.31.1
dc78def55f2c.mylabserver.com   Ready    <none>          34d   v1.31.1
dc78def55f3c.mylabserver.com   Ready    <none>          34d   v1.31.1
root@dc78def55f1c:/etc/kubernetes/manifests# 
root@dc78def55f1c:/etc/kubernetes/manifests# 
root@dc78def55f1c:/etc/kubernetes/manifests# 
root@dc78def55f1c:/etc/kubernetes/manifests# k get node -l disktype=ssd
NAME                           STATUS   ROLES    AGE   VERSION
dc78def55f3c.mylabserver.com   Ready    <none>   34d   v1.31.1
root@dc78def55f1c:/etc/kubernetes/manifests# 



k describe pod nginxlabel 

^Croot@dc78def55f1c:~# k describe pod nginxlabel 
Name:             nginxlabel
Namespace:        default
...
Node-Selectors:              disktype=hdd
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  26s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.


root@dc78def55f1c:~# k label nodes dc78def55f3c.mylabserver.com disktype=ssd1
error: 'disktype' already has a value (ssd), and --overwrite is false
root@dc78def55f1c:~# k label nodes dc78def55f3c.mylabserver.com disktype=ssd1 --overwrite 
node/dc78def55f3c.mylabserver.com labeled
root@dc78def55f1c:~# 

root@dc78def55f1c:~# k get node -l disktype=ssd
No resources found
root@dc78def55f1c:~# k get node -l disktype=ssd1
NAME                           STATUS   ROLES    AGE   VERSION
dc78def55f3c.mylabserver.com   Ready    <none>   34d   v1.31.1
root@dc78def55f1c:~# 


```