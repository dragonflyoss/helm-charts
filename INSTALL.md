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
      - containerPort: 65001
        hostPort: 65001
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
$ helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set dfdaemon.config.download.prefetch=true,seedPeer.config.download.prefetch=true
NAME: dragonfly
LAST DEPLOYED: Fri Apr  7 10:35:12 2023
NAMESPACE: dragonfly-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the scheduler address by running these commands:
  export SCHEDULER_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=scheduler" -o jsonpath={.items[0].metadata.name})
  export SCHEDULER_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $SCHEDULER_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  kubectl --namespace dragonfly-system port-forward $SCHEDULER_POD_NAME 8002:$SCHEDULER_CONTAINER_PORT
  echo "Visit http://127.0.0.1:8002 to use your scheduler"

2. Get the dfdaemon port by running these commands:
  export DFDAEMON_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=dfdaemon" -o jsonpath={.items[0].metadata.name})
  export DFDAEMON_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $DFDAEMON_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  You can use $DFDAEMON_CONTAINER_PORT as a proxy port in Node.

3. Configure runtime to use dragonfly:
  https://d7y.io/docs/getting-started/quick-start/kubernetes/
```

<!-- markdownlint-restore -->

Check that Dragonfly is deployed successfully:

```shell
$ kubectl wait po --all -n dragonfly-system --for=condition=ready --timeout=10m
pod/dragonfly-dfdaemon-gs924 condition met
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
pod/dragonfly-seed-peer-0 condition met
pod/dragonfly-seed-peer-1 condition met
pod/dragonfly-seed-peer-2 condition met
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
$ DFDAEMON_POD_NAME=`kubectl -n dragonfly-system get pod -l component=dfdaemon --no-headers -o custom-columns=NAME:metadata.name`
$ kubectl -n dragonfly-system exec -it ${DFDAEMON_POD_NAME} -- sh -c 'grep "peer task done" /var/log/dragonfly/daemon/core.log'
{"level":"info","ts":"2023-04-10 07:30:57.596","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 1116ms","peer":"10.244.0.5-1-53419631-8a14-4325-b5f2-c4ef01a02853","task":"d6a7aaa926dccd3376f91378f58d3a1a0871302d0afee718fd991a6849b422a7","component":"PeerTask","trace":"977c114a06b6d3a12fc680b28b57a43d"}
{"level":"info","ts":"2023-04-10 07:30:58.594","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 2116ms","peer":"10.244.0.5-1-4c45ed29-4931-4cfc-a8e7-ba06a7575518","task":"984629e0ba47eeccd65ffea34d1369d71bb821169c83918795cceb4e9774d3eb","component":"PeerTask","trace":"e9249680e787c9a13935aee1b280665a"}
{"level":"info","ts":"2023-04-10 07:30:58.598","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 2133ms","peer":"10.244.0.5-1-45e3cd5b-cac6-43f0-be82-398cab978e83","task":"571f792ad3e2b12cc28407f8f14d17a44925e0151aff947773bdac5bec64b8d6","component":"PeerTask","trace":"f4e79e09ac293603875b9542c9b24bb4"}
{"level":"info","ts":"2023-04-10 07:30:58.905","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 2377ms","peer":"10.244.0.5-1-6d51916a-13cb-4e50-8ba0-886e786e32eb","task":"023b961410d8776250215268f3569fa4ccb01bf1c557ca0e73888c4dd8c23ace","component":"PeerTask","trace":"285f5ecf084873e4311526136438d571"}
{"level":"info","ts":"2023-04-10 07:30:59.452","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 538ms","peer":"10.244.0.5-1-b7b2235f-4b0f-4253-8a1f-cdf7bd86f096","task":"23dee111679d459440e4839200940534037f1ba101bd7b7af57c9b7123f96882","component":"PeerTask","trace":"63d5147c7bd01455ce3c537f18463b12"}
{"level":"info","ts":"2023-04-10 07:31:01.722","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 4123ms","peer":"10.244.0.5-1-0dbbfe12-df46-4e3b-98dc-fa6c8f2a514c","task":"15c51bc09cf57b4c5c1c04e9cbdf17fa4560c6ad10b5b32680f0b8cd63bb900b","component":"PeerTask","trace":"b9bcac5bfe5d1f1871db22911d7d71b5"}
{"level":"info","ts":"2023-04-10 07:31:02.897","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 6483ms","peer":"10.244.0.5-1-be485ea5-6d54-4f56-8f56-bdbe76ec8469","task":"0fe34e3fcb64d49b09fe7c759f47a373b7590fe4dbe1da6d9c732eee516e4cb4","component":"PeerTask","trace":"daa2ffd1021779dfbd3162ead765e0ba"}
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
seedPeer:
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
$ helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set dfdaemon.config.download.prefetch=true,seedPeer.config.download.prefetch=true-f d7y-config.yaml
NAME: dragonfly
LAST DEPLOYED: Fri Apr  7 10:35:12 2023
NAMESPACE: dragonfly-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the scheduler address by running these commands:
  export SCHEDULER_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=scheduler" -o jsonpath={.items[0].metadata.name})
  export SCHEDULER_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $SCHEDULER_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  kubectl --namespace dragonfly-system port-forward $SCHEDULER_POD_NAME 8002:$SCHEDULER_CONTAINER_PORT
  echo "Visit http://127.0.0.1:8002 to use your scheduler"

2. Get the dfdaemon port by running these commands:
  export DFDAEMON_POD_NAME=$(kubectl get pods --namespace dragonfly-system -l "app=dragonfly,release=dragonfly,component=dfdaemon" -o jsonpath={.items[0].metadata.name})
  export DFDAEMON_CONTAINER_PORT=$(kubectl get pod --namespace dragonfly-system $DFDAEMON_POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  You can use $DFDAEMON_CONTAINER_PORT as a proxy port in Node.

3. Configure runtime to use dragonfly:
  https://d7y.io/docs/getting-started/quick-start/kubernetes/
```

<!-- markdownlint-restore -->

Check that Dragonfly is deployed successfully:

```shell
$ kubectl wait po --all -n dragonfly-system --for=condition=ready --timeout=10m
pod/dragonfly-dfdaemon-gs924 condition met
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
pod/dragonfly-seed-peer-0 condition met
pod/dragonfly-seed-peer-1 condition met
pod/dragonfly-seed-peer-2 condition met
```
