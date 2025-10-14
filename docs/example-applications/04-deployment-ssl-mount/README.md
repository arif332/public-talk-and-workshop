# Deployment SSL Mount

Let say you have secret


Imperative command:
```bash
kubectl create secret tls NAME --cert=path/to/cert/file --key=path/to/key/file [--dry-run=server|client|none]

# Create a new TLS secret named tls-secret with the given key pair
kubectl create secret tls tls-secret --cert=path/to/tls.crt --key=path/to/tls.key

```


Declarative yaml file:
```bash
# $ cat sslsecret.yml
apiVersion: v1
kind: Secret
metadata:
 name: nginx-ssl
type: Opaque
data:
 nginx.key: L...
 nginx.crt: DRV...
```

```bash
kubectl apply -f sslsecret.yml
```


Imperative command for depyment:
```bash
k create deployment nginx-deployment --image=nginx -r 3
```


Generate deployment yaml using imperative command:
```bash
k create deployment nginx-deployment --image=nginx -r 3 --dry-run=client -o yaml
```

Exmaple deployment yaml file:
```bash
apiVersion:  apps/v1
kind: Deployment 
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
          - mountPath: "/etc/nginx/ssl"
            name: nginx-ssl
            readOnly: true
        ports:
        - containerPort: 80
      volumes:
        - name: nginx-ssl
          secret:
            secretName: nginx-ssl
      restartPolicy: Always
```





# References