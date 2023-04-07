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

Create kind cluster configuration file `kind-config.yaml`, configuration content is as follows:

```shell
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.23.4
    extraMounts:
      - hostPath: /tmp/artifact
        containerPath: /tmp/artifact
      - hostPath: /dev/fuse
        containerPath: /dev/fuse
  - role: worker
    image: kindest/node:v1.23.4
    extraMounts:
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
 ✓ Ensuring node image (kindest/node:v1.23.4) 🖼
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
$ kubectl get po -n dragonfly-system
NAME                                 READY   STATUS    RESTARTS        AGE
dragonfly-dfdaemon-9c6h9             1/1     Running   5 (2m18s ago)   4m11s
dragonfly-manager-7cbdb5cc86-8fzrm   1/1     Running   0               4m11s
dragonfly-manager-7cbdb5cc86-pfljn   1/1     Running   0               4m11s
dragonfly-manager-7cbdb5cc86-pjqd9   1/1     Running   0               4m11s
dragonfly-mysql-0                    1/1     Running   0               4m11s
dragonfly-redis-master-0             1/1     Running   0               4m11s
dragonfly-redis-replicas-0           1/1     Running   1 (2m56s ago)   4m11s
dragonfly-redis-replicas-1           1/1     Running   0               2m31s
dragonfly-redis-replicas-2           1/1     Running   0               2m2s
dragonfly-scheduler-0                1/1     Running   0               4m11s
dragonfly-scheduler-1                1/1     Running   0               2m11s
dragonfly-scheduler-2                1/1     Running   0               119s
dragonfly-seed-peer-0                1/1     Running   2 (2m29s ago)   4m11s
dragonfly-seed-peer-1                1/1     Running   0               2m3s
dragonfly-seed-peer-2                1/1     Running   0               111s
```

## Install Nydus based on Helm Charts

Install Nydus using the default configuration, and the default configuration of Nydus Charts
will pull images from the [Docker Hub](https://hub.docker.com/).
For more information about mirrors configuration, please refer to
[Enable Mirror For Storage Backend Recommend](https://github.com/dragonflyoss/image-service/blob/902fd7181984e7fc31f6640b142162a787047ac9/docs/nydusd.md#enable-mirrors-for-storage-backend-recommend).

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
$ kubectl get po -n dragonfly-system
NAME                                 READY   STATUS    RESTARTS       AGE
dragonfly-dfdaemon-rhnr6             1/1     Running   4 (101s ago)   3m27s
dragonfly-dfdaemon-s6sv5             1/1     Running   5 (111s ago)   3m27s
dragonfly-manager-67f97d7986-8dgn8   1/1     Running   0              3m27s
dragonfly-mysql-0                    1/1     Running   0              3m27s
dragonfly-redis-master-0             1/1     Running   0              3m27s
dragonfly-redis-replicas-0           1/1     Running   1 (115s ago)   3m27s
dragonfly-redis-replicas-1           1/1     Running   0              95s
dragonfly-redis-replicas-2           1/1     Running   0              70s
dragonfly-scheduler-0                1/1     Running   0              3m27s
dragonfly-seed-peer-0                1/1     Running   2 (95s ago)    3m27s
```

<!-- markdownlint-restore -->

## Run Container With Nydus

### 3.1 Wait for Nydus components to be ready

```shell
pod=`kubectl -n nydus-snapshotter get pods --no-headers -o custom-columns=NAME:metadata.name`
echo "snapshotter pod name ${pod}"
# Wait for Nydus components to be ready
kubectl -n nydus-snapshotter wait po $pod --for=condition=ready --timeout=2m
```

The process may wait for about ten seconds.

```shell
$ kubectl -n nydus-snapshotter wait po $pod --for=condition=ready --timeout=2m
snapshotter pod name nydus-snapshotter-bkmkr
pod/nydus-snapshotter-bkmkr condition met
```

### 3.2 Start the pod based on the Nydus image

```shell
cat <<EOF > nydus-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nydus-pod
spec:
  containers:
    - name: nginx
      image: ghcr.io/dragonflyoss/image-service/nginx:nydus-latest
      imagePullPolicy: Always
      command: ["sh", "-c"]
      args:
        - tail -f /dev/null
EOF

kubectl apply -f ./nydus-pod.yaml
kubectl wait po nydus-pod --for=condition=ready --timeout=1m
kubectl exec -ti nydus-pod  -- date
```

If the date is successfully output, it means that the nydus pod started successfully.

```shell
$ kubectl exec -ti nydus-pod  -- date
Thu Apr  6 07:22:11 UTC 2023
```

### 3.3 Convert Nydus image (optional)

In the above section we used a pre-converted Nydus image: `ghcr.io/dragonflyoss/image-service/nginx:nydus-latest`

You can also use [Nydusify](https://github.com/dragonflyoss/image-service/blob/master/docs/nydusify.md)
to convert new Nydus images from OCI images.

```bash
sudo nerdctl run -d --restart=always -p 5000:5000 registry
sudo nydusify convert --fs-version 6 --source ubuntu --target localhost:5000/ubuntu-nydus
```

## 4. Verification successful

### 4.1 Verify that the download traffic via Dragonfly

```shell
pod_name=`kubectl -n dragonfly-system get pod -l component=dfdaemon --no-headers -o custom-columns=NAME:metadata.name`
kubectl -n dragonfly-system exec -it ${pod_name} -- sh -c 'grep "peer task done" /var/log/dragonfly/daemon/core.log'
```

The following log shows that Dragonfly can pull the image.

<!-- markdownlint-disable -->

```shell
$ pod_name=`kubectl -n dragonfly-system get pod -l component=dfdaemon --no-headers -o custom-columns=NAME:metadata.name`
$ kubectl -n dragonfly-system exec -it ${pod_name} -- sh -c 'grep "peer task done" /var/log/dragonfly/daemon/core.log'
Defaulted container "dfdaemon" out of: dfdaemon, wait-for-scheduler (init), mount-netns (init)
{"level":"info","ts":"2023-04-06 07:22:08.477","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 759ms","peer":"10.244.0.9-1-f48c0993-14aa-4436-93d1-f1cb790d7631","task":"023b961410d8776250215268f3569fa4ccb01bf1c557ca0e73888c4dd8c23ace","component":"PeerTask","trace":"7dd6c5401af251265458dd6ab2171bad"}
{"level":"info","ts":"2023-04-06 07:22:08.506","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 860ms","peer":"10.244.0.9-1-747ae0c6-72fc-4f61-af55-931cad58e1a7","task":"39e00f986b2a2dbe0010c94e426596531497887ab15c266803334a464f84210e","component":"PeerTask","trace":"45257d1995c11cf46a1d43aa66b16c60"}
```

<!-- markdownlint-restore -->

### 5. Conclusion

So far, you have deployed Dragonfly & Nydus in the test environment. The deployment in the production environment
needs further configuration. Please refer to the official documentation:

- [https://d7y.io/docs/](https://d7y.io/docs/)
- [https://github.com/dragonflyoss/image-service#documentation](https://github.com/dragonflyoss/image-service#documentation)

## Remark

### Configuration on [Alibaba Cloud ACK](https://www.alibabacloud.com/product/kubernetes)

Since the environment of ACK is different from that of Kind, it is necessary to
additionally configure Dragonfly's storage volume declaration with the following parameters in section 2.1.

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

helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set dfdaemon.config.download.prefetch=true,seedPeer.config.download.prefetch=true -f d7y-config.yaml
```

<!-- markdownlint-restore -->
