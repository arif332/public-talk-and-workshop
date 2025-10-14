**Table of Contents:**
- [1. Secrets](#1-secrets)
  - [1.1. Secrets Mount to Pod](#11-secrets-mount-to-pod)
  - [1.2. Define container environment variables using Secret data](#12-define-container-environment-variables-using-secret-data)
  - [1.3. ConfigMaps and Pods](#13-configmaps-and-pods)
  - [1.4. Define an environment variable for a container](#14-define-an-environment-variable-for-a-container)
- [2. References](#2-references)



# 1. Secrets

## 1.1. Secrets Mount to Pod

[secret-mount-to-pod.yaml](secret-mount-to-pod.yaml)

Create secrets and mount those secrets to pod:
```bash
kubectl apply -f secret-mount-to-pod.yaml
```

Get a shell into the Container that is running in your Pod:
```bash
kubectl exec -i -t secret-test-pod -- /bin/bash
```

In your shell, list the files in the /etc/secret-volume directory:
```bash
# Run this in the shell inside the container
ls /etc/secret-volume

# Run this in the shell inside the container
echo "$( cat /etc/secret-volume/username )"
echo "$( cat /etc/secret-volume/password )"
```


## 1.2. Define container environment variables using Secret data 

```bash
kubectl create secret generic backend-user --from-literal=backend-username='backend-admin'
```

[pod-single-secret-env-variable.yaml](./pod-single-secret-env-variable.yaml)

```yaml
# filename: pod-single-secret-env-variable.yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-single-secret
spec:
  containers:
  - name: envars-test-container
    image: nginx
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: backend-user
          key: backend-username
```

Create pod:
```bash
kubectl create -f pod-single-secret-env-variable.yaml
```

In your shell, display the content of SECRET_USERNAME container environment variable.
```bash
kubectl exec -i -t env-single-secret -- /bin/sh -c 'echo $SECRET_USERNAME'
```

## 1.3. ConfigMaps and Pods

This is an example of a Pod that mounts a ConfigMap in a volume:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    configMap:
      name: myconfigmap
```


The following Pod consumes the content of the ConfigMap as environment variables:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-configmap
spec:
  containers:
    - name: app
      command: ["/bin/sh", "-c", "printenv"]
      image: busybox:latest
      envFrom:
        - configMapRef:
            name: myconfigmap
```


[env-mount-configmap-pod.yaml](./env-mount-configmap-pod.yaml)

```bash
kubectl apply -f env-mount-configmap-pod.yaml
```

**Note:**
- ConfigMaps consumed as environment variables are not updated automatically and require a pod restart.


## 1.4. Define an environment variable for a container

```yaml
# envars.yaml
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/hello-app:2.0
    env:
    - name: DEMO_GREETING
      value: "Hello from the environment"
    - name: DEMO_FAREWELL
      value: "Such a sweet sorrow"
```

```bash
kubectl apply -f envars.yaml
```

List the Pod's container environment variables:
```bash
kubectl exec envar-demo -- printenv
```



# 2. References
- https://kubernetes.io/docs/concepts/configuration/secret/
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume
- https://kubernetes.io/docs/concepts/configuration/configmap/
