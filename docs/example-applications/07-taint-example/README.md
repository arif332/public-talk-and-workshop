

```bash
root@dc78def55f1c:~# cat taint-example.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-taint
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    node-role.kubernetes.io/control-plane: "" 
```

```bash
root@dc78def55f1c:~# k get node -l node-role.kubernetes.io/control-plane=
NAME                           STATUS   ROLES           AGE   VERSION
dc78def55f1c.mylabserver.com   Ready    control-plane   34d   v1.31.1
root@dc78def55f1c:~# 


root@dc78def55f1c:~# k describe node dc78def55f1c.mylabserver.com |grep -A5 -i taint 
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  dc78def55f1c.mylabserver.com
  AcquireTime:     <unset>
  RenewTime:       Thu, 07 Nov 2024 17:34:36 +0000
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-taint
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
```

```bash
root@dc78def55f1c:~# k describe pod nginx-taint |grep -A 4 -i Tolerations
Tolerations:                 node-role.kubernetes.io/control-plane:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
...


k describe node |grep -A4 Taint  
```



Scale:

```bash

```


```bash
root@dc78def55f1c:~# k autoscale deployment --max 5 --min 2 nginx-deployment 
horizontalpodautoscaler.autoscaling/nginx-deployment autoscaled
root@dc78def55f1c:~# 

root@dc78def55f1c:~# k get  horizontalpodautoscalers.autoscaling 
NAME               REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
nginx-deployment   Deployment/nginx-deployment   cpu: <unknown>/80%   2         5         4          51s
```


```bash
root@dc78def55f1c:~# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
poddisruptionbudget.policy/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
root@dc78def55f1c:~# 

root@dc78def55f1c:~# k logs metrics-server-788b46889b-4k5xd 
I1107 17:52:34.089539       1 serving.go:374] Generated self-signed cert (/tmp/apiserver.crt, /tmp/apiserver.key)
I1107 17:52:34.789553       1 handler.go:275] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
E1107 17:52:34.902415       1 scraper.go:149] "Failed to scrape node" err="Get \"https://172.31.43.120:10250/metrics/resource\": tls: failed to verify certificate: x509: cannot validate certificate for 172.31.43.120 because it doesn't contain any IP SANs" node="dc78def55f2c.mylabserver.com"


# add 
# k edit deployments.apps metrics-server
--kubelet-insecure-tls
```


Ref:
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/