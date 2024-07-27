# Install Dragonfly & Nydus on Kubernetes

This document will help you experience how to use [Dragonfly](https://d7y.io) & [Nydus](https://nydus.dev/).

## Prerequisites

<!-- markdownlint-disable -->

| Name    | Version   | Document                                                 |
| ------- | --------- | -------------------------------------------------------- |
| Kind    | v0.17.0+  | [kind.sigs.k8s.io](https://kind.sigs.k8s.io/)            |
| Helm    | v3.11.0+  | [helm.sh](https://helm.sh/)                              |
| kubectl | v1.23.17+ | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| docker  | v23.0.3+  | [docker.com](https://docs.docker.com/engine/install/)    |

<!-- markdownlint-restore -->

**Notice:** [Kind](https://kind.sigs.k8s.io/) is recommended if no kubernetes cluster is available for testing.

## Setup kubernetes cluster

Download containerd configuration for kind.

```shell
curl -fsSL -o config.toml https://raw.githubusercontent.com/dragonflyoss/Dragonfly2/main/test/testdata/containerd/config.toml
```

Create kind cluster configuration file `kind-config.yaml`, configuration content is as follows:

```shell
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: dual
nodes:
  - role: control-plane
    image: kindest/node:v1.23.17
    extraPortMappings:
      - containerPort: 4001
        hostPort: 4001
        protocol: TCP
    extraMounts:
      - hostPath: ./config.toml
        containerPath: /etc/containerd/config.toml
      - hostPath: /tmp/artifact
        containerPath: /tmp/artifact
      - hostPath: /dev/fuse
        containerPath: /dev/fuse
EOF
```

Create a kind cluster using the configuration file:

```shell
$ kind create cluster --config kind-config.yaml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.23.17) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊
```

Switch the context of kubectl to kind cluster:

```shell
kubectl config use-context kind-kind
```

## Install Dragonfly based on Helm Charts

Install Dragonfly using the configuration:

<!-- markdownlint-disable -->

```shell
$ helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
$ helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set client.config.proxy.prefetch=true,seedClient.config.proxy.prefetch=true
NAME: dragonfly
LAST DEPLOYED: Fri Apr  7 10:35:12 2023
NAMESPACE: dragonfly-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the scheduler address by running these commands:
  export SCHEDULER_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=scheduler" -o jsonpath="{.items[0].metadata.name}")
  export SCHEDULER_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $SCHEDULER_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  kubectl --namespace dragonfly-system port-forward $SCHEDULER_POD_NAME 8002:$SCHEDULER_CONTAINER_PORT
  echo "Visit http://127.0.0.1:8002 to use your scheduler"

2. Configure runtime to use dragonfly:
  https://d7y.io/docs/getting-started/quick-start/kubernetes/
```

<!-- markdownlint-restore -->

Check that Dragonfly is deployed successfully:

```shell
$ kubectl wait po --all -n dragonfly-system --for=condition=ready --timeout=10m
pod/dragonfly-client-gs924 condition met
pod/dragonfly-manager-5d97fd88fb-txnw9 condition met
pod/dragonfly-manager-5d97fd88fb-v2nmh condition met
pod/dragonfly-manager-5d97fd88fb-xg6wr condition met
pod/dragonfly-mysql-0 condition met
pod/dragonfly-redis-master-0 condition met
pod/dragonfly-redis-replicas-0 condition met
pod/dragonfly-redis-replicas-1 condition met
pod/dragonfly-redis-replicas-2 condition met
pod/dragonfly-scheduler-0 condition met
pod/dragonfly-scheduler-1 condition met
pod/dragonfly-scheduler-2 condition met
pod/dragonfly-seed-client-0 condition met
pod/dragonfly-seed-client-1 condition met
pod/dragonfly-seed-client-2 condition met
```

## Install Nydus based on Helm Charts

Install Nydus using the default configuration, for more information about mirrors configuration, please refer to
[document](https://github.com/dragonflyoss/image-service/blob/master/docs/nydusd.md#enable-mirrors-for-storage-backend-recommend).

<!-- markdownlint-disable -->

```shell
$ curl -fsSL -o config-nydus.yaml https://raw.githubusercontent.com/dragonflyoss/Dragonfly2/main/test/testdata/charts/config-nydus.yaml
$ helm install --wait --timeout 10m --dependency-update --create-namespace --namespace nydus-snapshotter nydus-snapshotter dragonfly/nydus-snapshotter -f config-nydus.yaml
NAME: nydus-snapshotter
LAST DEPLOYED: Fri Apr  7 10:40:50 2023
NAMESPACE: nydus-snapshotter
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing nydus-snapshotter.

Your release is named nydus-snapshotter.

To learn more about the release, try:

  $ helm status nydus-snapshotter
  $ helm get all nydus-snapshotter
```

Check that Nydus is deployed successfully:

```shell
$ kubectl wait po --all -n nydus-snapshotter --for=condition=ready --timeout=1m
pod/nydus-snapshotter-6mwlv condition met
```

<!-- markdownlint-restore -->

## Run Nydus Image in Kubernetes

Create Nginx pod configuration file `nginx-nydus.yaml` with Nydus image `ghcr.io/dragonflyoss/image-service/nginx:nydus-latest`.
For more details about how to build nydus image, please refer to
the [document](https://github.com/dragonflyoss/image-service/blob/master/docs/containerd-env-setup.md#convertbuild-an-image-to-nydus-format).

```shell
cat <<EOF > nginx-nydus.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: ghcr.io/dragonflyoss/image-service/nginx:nydus-latest
      imagePullPolicy: Always
      command: ["sh", "-c"]
      args:
        - tail -f /dev/null
EOF
```

Create a Nginx pod using the configuration file:

```shell
kubectl apply -f nginx-nydus.yaml
```

Check that Nginx is deployed successfully:

```shell
$ kubectl wait po nginx --for=condition=ready --timeout=1m
pod/nginx condition met
```

Executing the `date` command in the Nginx container.

```shell
$ kubectl exec -it nginx -- date
Mon Apr 10 07:57:38 UTC 2023
```

## Verify downloaded Nydus image via Dragonfly

Verify downloaded Nydus image via Dragonfly based on mirror mode:

<!-- markdownlint-disable -->

```shell
$ CLIENT_POD_NAME=`kubectl -n dragonfly-system get pod -l component=client --no-headers -o custom-columns=NAME:metadata.name`
$ kubectl -n dragonfly-system exec -it ${CLIENT_POD_NAME} -- sh -c 'grep "download task succeeded" /var/log/dragonfly/dfdaemon/dfdaemon.log'
2024-05-28T12:36:24.861903Z INFO download_task: dragonfly-client/src/grpc/dfdaemon_download.rs:276: download task succeeded host_id="127.0.0.1-kind-worker" task_id="4535f073321f0d1908b8c3ad63a1d59324573c0083961c5bcb7f38ac72ad598d" peer_id="127.0.0.1-kind-worker-13095fb5-786a-4908-b8c1-744be144b383"
```

<!-- markdownlint-restore -->

## Performance testing

Test the performance of single-machine image download after the integration of Dragonfly and Nydus,
please refer to [document](https://d7y.io/docs/setup/integration/nydus).

## Notes

### Install Dragonfly and Nydus in [Alibaba Cloud ACK](https://www.alibabacloud.com/product/kubernetes)

If you are using Dragonfly and Nydus in [Alibaba Cloud ACK](https://www.alibabacloud.com/product/kubernetes),
you should follow the steps when deploying Dragonfly.

Create Draognfly configuration file `d7y-config.yaml`, configuration content is as follows:

<!-- markdownlint-disable -->

```shell
cat <<EOF > d7y-config.yaml
seedClient:
  persistence:
    storageClass: "alicloud-disk-essd"
    size: 20Gi

redis:
  master:
    persistence:
      storageClass: "alicloud-disk-essd"
      size: 20Gi
  replica:
    persistence:
      storageClass: "alicloud-disk-essd"
      size: 20Gi

mysql:
  primary:
    persistence:
      storageClass: "alicloud-disk-essd"
      size: 20Gi
EOF
```

<!-- markdownlint-restore -->

Install Dragonfly using the params:

<!-- markdownlint-disable -->

```shell
$ helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
$ helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set client.config.proxy.prefetch=true,seedClient.config.proxy.prefetch=true-f d7y-config.yaml
NAME: dragonfly
LAST DEPLOYED: Fri Apr  7 10:35:12 2023
NAMESPACE: dragonfly-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the scheduler address by running these commands:
  export SCHEDULER_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=scheduler" -o jsonpath="{.items[0].metadata.name}")
  export SCHEDULER_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $SCHEDULER_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  kubectl --namespace dragonfly-system port-forward $SCHEDULER_POD_NAME 8002:$SCHEDULER_CONTAINER_PORT
  echo "Visit http://127.0.0.1:8002 to use your scheduler"

2. Configure runtime to use dragonfly:
  https://d7y.io/docs/getting-started/quick-start/kubernetes/
```

<!-- markdownlint-restore -->

Check that Dragonfly is deployed successfully:

```shell
$ kubectl wait po --all -n dragonfly-system --for=condition=ready --timeout=10m
pod/dragonfly-client-gs924 condition met
pod/dragonfly-manager-5d97fd88fb-txnw9 condition met
pod/dragonfly-manager-5d97fd88fb-v2nmh condition met
pod/dragonfly-manager-5d97fd88fb-xg6wr condition met
pod/dragonfly-mysql-0 condition met
pod/dragonfly-redis-master-0 condition met
pod/dragonfly-redis-replicas-0 condition met
pod/dragonfly-redis-replicas-1 condition met
pod/dragonfly-redis-replicas-2 condition met
pod/dragonfly-scheduler-0 condition met
pod/dragonfly-scheduler-1 condition met
pod/dragonfly-scheduler-2 condition met
pod/dragonfly-seed-client-0 condition met
pod/dragonfly-seed-client-1 condition met
pod/dragonfly-seed-client-2 condition met
```
