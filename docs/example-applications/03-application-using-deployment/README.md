# Kubernetes Application Using Deployment


Create a deployment and expose service:
```bash
k create deployment nginx-deployment --image=nginx -r 3

#port=service port, target-port=pod port,
k expose deployment nginx-deployment --port=80 --target-port=8080 --name nginx-svc
```


# Scaling a Deployment

You can scale a Deployment by using the following command:
```bash
kubectl scale deployment/nginx-deployment --replicas=5
```


You can set up an autoscaler for your Deployment and choose the minimum and maximum number of Pods you want to run based on the CPU utilization of your existing Pods.

```bash
kubectl autoscale deployment/nginx-deployment --min=2 --max=5 --cpu-percent=80
```


# References
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/