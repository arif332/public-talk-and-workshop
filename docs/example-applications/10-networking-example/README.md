**Table of Contents:**
- [1. Networking](#1-networking)
  - [1.1. Default policies](#11-default-policies)
  - [1.2. Default deny all ingress traffic](#12-default-deny-all-ingress-traffic)
  - [1.3. Allow all ingress traffic](#13-allow-all-ingress-traffic)
  - [1.4. Default deny all egress traffic](#14-default-deny-all-egress-traffic)
  - [1.5. Allow all egress traffic](#15-allow-all-egress-traffic)
  - [1.6. Default deny all ingress and all egress traffic](#16-default-deny-all-ingress-and-all-egress-traffic)
  - [1.7. Example of Network Policy](#17-example-of-network-policy)
- [2. References](#2-references)


# 1. Networking

## 1.1. Default policies
>By default, if no policies exist in a namespace, then all ingress and egress traffic is allowed to and from pods in that namespace. The following examples let you change the default behavior in that namespace.

## 1.2. Default deny all ingress traffic
>You can create a "default" ingress isolation policy for a namespace by creating a NetworkPolicy that selects all pods but does not allow any ingress traffic to those pods.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress

```

## 1.3. Allow all ingress traffic 

>You can create a "default" ingress isolation policy for a namespace by creating a NetworkPolicy that selects all pods but does not allow any ingress traffic to those pods.

[network-policy-allow-all-ingress.yaml](./network-policy-allow-all-ingress.yaml)

```yaml
# network-policy-allow-all-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
```

```bash
k apply -f network-policy-allow-all-ingress.yaml
```


## 1.4. Default deny all egress traffic

[network-policy-default-deny-all.yaml]
```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

## 1.5. Allow all egress traffic
>If you want to allow all connections from all pods in a namespace, you can create a policy that explicitly allows all outgoing connections from pods in that namespace.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-egress
spec:
  podSelector: {}
  egress:
  - {}
  policyTypes:
  - Egress
```

## 1.6. Default deny all ingress and all egress traffic

>You can create a "default" policy for a namespace which prevents all ingress AND egress traffic by creating the following NetworkPolicy in that namespace.

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```


## 1.7. Example of Network Policy  


```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

Ref:
- https://kubernetes.io/docs/concepts/services-networking/network-policies/#networkpolicy-resource





# 2. References
- https://kubernetes.io/docs/concepts/services-networking/network-policies/