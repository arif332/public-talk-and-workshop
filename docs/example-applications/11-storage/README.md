# Storage

>A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like a node is a cluster resource. PVs are volume plugins like Volumes, but have a lifecycle independent of any individual Pod that uses the PV. This API object captures the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system. 


>A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., they can be mounted ReadWriteOnce, ReadOnlyMany, ReadWriteMany, or ReadWriteOncePod, see AccessModes).


![](./../../image/design-diagram-v1-storage.jpg)


[Install local-path-storage Provisioner](https://github.com/rancher/local-path-provisioner)

Installation logs:
```bash
root@dc78def55f1c:~# 
root@dc78def55f1c:~# kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml
namespace/local-path-storage created
serviceaccount/local-path-provisioner-service-account created
role.rbac.authorization.k8s.io/local-path-provisioner-role created
clusterrole.rbac.authorization.k8s.io/local-path-provisioner-role created
rolebinding.rbac.authorization.k8s.io/local-path-provisioner-bind created
clusterrolebinding.rbac.authorization.k8s.io/local-path-provisioner-bind created
deployment.apps/local-path-provisioner created
storageclass.storage.k8s.io/local-path created
configmap/local-path-config created
root@dc78def55f1c:~# k get sc
NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  46s
root@dc78def55f1c:~# 
```



Create Persistence Volume Claim (PVC):

```bash
root@dc78def55f1c:~# k get pvc
No resources found in local-path-storage namespace.
root@dc78def55f1c:~# kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pvc/pvc.yaml
persistentvolumeclaim/local-path-pvc created


root@dc78def55f1c:~# k get pvc
NAME             STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
local-path-pvc   Pending                                      local-path     <unset>                 12s
root@dc78def55f1c:~# 


root@dc78def55f1c:~# kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/examples/pod/pod.yaml
pod/volume-test created
root@dc78def55f1c:~# k get pod
NAME                                                         READY   STATUS              RESTARTS   AGE
helper-pod-create-pvc-56ea3615-de62-427e-88aa-81cdf83159a4   0/1     ContainerCreating   0          3s
local-path-provisioner-dbff48958-jmx8w                       1/1     Running             0          7m3s
volume-test                                                  0/1     Pending             0          3s
root@dc78def55f1c:~# k get pod
NAME                                     READY   STATUS              RESTARTS   AGE
local-path-provisioner-dbff48958-jmx8w   1/1     Running             0          7m7s
volume-test                              0/1     ContainerCreating   0          7s
root@dc78def55f1c:~# k get pod -w
NAME                                     READY   STATUS              RESTARTS   AGE
local-path-provisioner-dbff48958-jmx8w   1/1     Running             0          7m11s
volume-test                              0/1     ContainerCreating   0          11s
^Croot@dc78def55f1c:~# k get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
local-path-pvc   Bound    pvc-56ea3615-de62-427e-88aa-81cdf83159a4   128Mi      RWO            local-path     <unset>                 55s
root@dc78def55f1c:~# 


root@dc78def55f1c:~# k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-56ea3615-de62-427e-88aa-81cdf83159a4   128Mi      RWO            Delete           Bound    local-path-storage/local-path-pvc   local-path     <unset>                          66s
root@dc78def55f1c:~# 

```


[storageclass-local.yaml](./storageclass-local.yaml)


Ref:
- https://kubernetes.io/docs/concepts/storage/storage-classes/#local


>Kubernetes doesn't include an internal NFS provisioner. You need to use an external provisioner to create a StorageClass for NFS. Here are some examples:
[storageclass-nfs.yaml](./storageclass-nfs.yaml)

Ref:
- https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs
- https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner


# References
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistent-volumes