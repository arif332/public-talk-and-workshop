# Exmaple of a Kustomization


>The term kustomization refers to a [kustomization.yaml](./base/kustomization.yaml) file, or more generally to a directory (the root) containing the kustomization.yaml file and all the relative file paths that it immediately references (all the local data that doesn’t require a URL specification).

>A base is a kustomization referred to by some other kustomization. Any kustomization, including an overlay, can be a base to another kustomization. A base has no knowledge of the overlays that refer to it. For simple gitops management, a base configuration could be the sole content of a git repository dedicated to that purpose. Same with overlays. Changes in a repo could generate a build, test and deploy cycle.



A kustomization file contains fields falling into four categories:
- resources - what existing resources are to be customized. Example fields: resources, crds.
- generators - what new resources should be created. Example fields: configMapGenerator (legacy), secretGenerator (legacy), generators (v2.1).
- transformers - what to do to the aforementioned resources. Example fields: namePrefix, nameSuffix, images, commonLabels, patchesJson6902, etc. and the more general transformers (v2.1) field.
- meta - fields which may influence all or some of the above. Example fields: vars, namespace, apiVersion, kind, etc.


>An overlay is a kustomization that depends on another kustomization. The kustomizations an overlay refers to (via file path, URI or other method) are called bases. An overlay is unusable without its bases. An overlay may act as a base to another overlay.

Overlays make the most sense when there is more than one, because they create different variants of a common base - e.g. development, QA, staging and production environment variants.




[For further check with me](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#kustomization)



Directory structure for example of Kustomize: 
```bash
.
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── dev
    │   ├── deployment-dev.yaml
    │   ├── kustomization.yaml
    │   └── service-dev.yaml
    └── prod
        ├── deployment-prod.yaml
        ├── kustomization.yaml
        └── service-prod.yaml
```

## Dev Deployment

Check manifest baed on `overlays/dev`:
```bash
kustomize build overlays/dev

# or
kubectl kustomize overlays/dev
```

We can deploy the customized manifest using the following command.
```bash
kustomize build overlays/dev | kubectl apply -f .
```

Or can be apply with below command:
```bash
kubectl apply -k overlays/dev
```


## Prod Deployment


Check manifest baed on `overlays/prod`:
```bash
kustomize build overlays/prod

# or
kubectl kustomize overlays/prod
```

We can deploy the customized manifest using the following command.
```bash
kustomize build overlays/prod | kubectl apply -f .
```

Or can be apply with below command:
```bash
kubectl apply -k overlays/prod
```


# Referneces
- https://subbaramireddyk.medium.com/kustomize-kubernetes-native-configuration-management-f51630d29ac0
- https://kustomize.io/
- https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_kustomize/