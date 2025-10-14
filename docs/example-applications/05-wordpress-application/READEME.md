# Wordpress Application Setup

In this section we will show how to setup a wordpress application in kubernetes platform. 


First create namespace for the wordpress application. 
```bash
kubectl create ns wordpress 
```


Now a create a secret for the mysql database that we are going to use while creating mysql database. 
```bash
kubectl create secret generic mysql-pass --from-literal password=YOUR_PASSWORD -n wordpress
```

Now create mysql database using [deployment manifest file](./k8s-mysql-deployment.yaml).
```bash
kubectl create -f k8s-mysql-deployment.yaml -n wordpress
```


Now create wordpress application using [depolyment manifest](./k8s-wordpress-deployment.yaml) file.
```bash
kubectl create -f k8s-wordpress-deployment.yaml -n wordpress
```

Now check application status:

```bash
aaa@hostmacOs wordpress-application % kubectl get deployment -n wordpress 
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
wordpress         1/1     1            1           3h22m
wordpress-mysql   1/1     1            1           3h24m

aaa@hostmacOs wordpress-application % kubectl get pod -n wordpress
NAME                               READY   STATUS    RESTARTS   AGE
wordpress-7867b7f788-wlg5p         1/1     Running   0          3h22m
wordpress-mysql-68fd75cb99-4hxfp   1/1     Running   0          3h24m
```

Now check service IP address of wordpress application:
```bash
aaa@hostmacOs wordpress-application % kubectl get svc -n wordpress 
NAME              TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
wordpress         LoadBalancer   10.96.51.49   <pending>     80:31416/TCP   49s
wordpress-mysql   ClusterIP      None          <none>        3306/TCP       3m19s
```

Now also check storage request for the deployment application.
```bash
aaa@hostmacOs wordpress-application % kubectl get pvc -n wordpress 
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mysql-pv-claim   Bound    pvc-1d34a3b3-1e56-47c8-82ac-abe080986235   1Gi        RWO            standard       <unset>                 11m
wp-pv-claim      Bound    pvc-acfe08e5-52c4-491c-9fbe-8b10005a2438   1Gi        RWO            standard       <unset>                 8m55s


aaa@hostmacOs wordpress-application % kubectl get pv -n wordpress 
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                        STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-1d34a3b3-1e56-47c8-82ac-abe080986235   1Gi        RWO            Delete           Bound    wordpress/mysql-pv-claim     standard       <unset>                          12m
pvc-7a1441da-8380-400d-92d8-913e973c3e26   1Gi        RWO            Delete           Bound    default/mysql-data-mysql-0   standard       <unset>                          37m
pvc-acfe08e5-52c4-491c-9fbe-8b10005a2438   1Gi        RWO            Delete           Bound    wordpress/wp-pv-claim        standard       <unset>                          9m32s
```


```bash
kubectl port-forward services/wordpress 9090:80 -n wordpress
```

Now browse wordpress site from your browser using `http://localhost:9090/`


# References
- https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/