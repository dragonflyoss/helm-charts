# Use Helm to quickly deploy Dragonfly & Nydus on K8S
# Introduction
In the cloud-native scenario, the operation of business systems is inseparable from the creation, distribution, and operation of images. In the process of using the current image, the full image needs to be pulled from the registry to the local, and then decompressed and mounted by the container engine before it can be provided to the container. In the actual production process, the distribution and loading of a large number of images is often the bottleneck that limits the speed of container startup.

In order to solve the above problems, we introduced the **image acceleration solution of [Dragonfly](d7y.io) & [Nydus](https://nydus.dev/)**. However, in the past deployment process, users need to manually install many components, which is costly. To this end, this article will introduce how to use the Kubernetes package management tool Helm to deploy the Dragonfly & Nydus solution on the K8S cluster simply and quickly.
# 1. Prepare k8s cluster
## 1.1 Prerequisites

You may need to install these tools to complete this tutorial.

<!-- markdownlint-disable -->

| Name                | Version | Document                                                    |
| ------------------- | ------- | ----------------------------------------------------------- |
| Kind    | v0.17.0+  | [kind.sigs.k8s.io](https://kind.sigs.k8s.io/)                         |
| Helm    | v3.11.0+  | [helm.sh](https://helm.sh/)                                           |
| kubectl | v1.23.17+ | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/)              |
| docker  | v23.0.3+  | [docker.com](https://docs.docker.com/engine/install/)                 |

<!-- markdownlint-restore -->

## 1.2 Use kind to create a cluster locally
In addition to kind, you can also deploy K8s clusters in other ways, but further configuration adjustments may be required.
In the remark chapter, we gave an example of deployment on [Alibaba Cloud ACK](https://www.alibabacloud.com/product/kubernetes)

```
wget https://raw.githubusercontent.com/dragonflyoss/Dragonfly2/main/test/testdata/containerd/config.toml

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

kind create cluster --config ./kind-config.yaml --name kind --wait 300s
```
It can be a long wait here. You can pull the image first to speed things up:

`docker pull kindest/node:v1.23.17`

``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# kind create cluster --config ./kind-config.yaml --name kind --wait 300s
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.23.17) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Waiting ≤ 5m0s for control-plane = Ready ⏳
 • Ready after 29s 💚
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊
```
# 2. Deploy with Helm
## 2.1 Install Dragonfly components
```
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set dfdaemon.config.download.prefetch=true,seedPeer.config.download.prefetch=true
```
It may take a long time to wait here. If the waiting time exceeds 10 minutes, it may be because:

- The server hardware configuration is low.

- The network is too slow to pull images.

``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# helm install --wait --timeout 10m --dependency-update --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly --set dfdaemon.config.download.prefetch=true,seedPeer.config.download.prefetch=true

NAME: dragonfly
LAST DEPLOYED: Thu Apr  6 15:10:12 2023
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
## 2.2 Install Nydus components
```
curl -fsSL -o config-nydus.yaml https://raw.githubusercontent.com/dragonflyoss/Dragonfly2/main/test/testdata/charts/config-nydus.yaml

helm install --wait --timeout 10m --dependency-update --create-namespace --namespace nydus-snapshotter nydus-snapshotter dragonfly/nydus-snapshotter -f config-nydus.yaml
```
In the configuration of `config-nydus.yaml`, there is a `X-Dragonfly-Registry` configuration that needs to be adjusted manually. You need to add the address of the image registry you need to use, such as "https://index.docker.io" corresponding to dockerHub, otherwise P2P acceleration may not take effect.

The process will be completed shortly.
``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# helm install --wait --timeout 10m --dependency-update --create-namespace --namespace nydus-snapshotter nydus-snapshotter dragonfly/nydus-snapshotter -f config-nydus.yaml
NAME: nydus-snapshotter
LAST DEPLOYED: Thu Apr  6 15:19:36 2023
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
# 3. Run Nydus image
## 3.1 Wait for Nydus components to be ready
```
pod=`kubectl -n nydus-snapshotter get pods --no-headers -o custom-columns=NAME:metadata.name`
echo "snapshotter pod name ${pod}"
# Wait for Nydus components to be ready
kubectl -n nydus-snapshotter wait po $pod --for=condition=ready --timeout=2m
```
The process may wait for about ten seconds.
``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# kubectl -n nydus-snapshotter wait po $pod --for=condition=ready --timeout=2m
snapshotter pod name nydus-snapshotter-bkmkr
pod/nydus-snapshotter-bkmkr condition met
```
## 3.2 Start the pod based on the Nydus image
```
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
``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# kubectl exec -ti nydus-pod  -- date
Thu Apr  6 07:22:11 UTC 2023
```

## 3.3 Convert Nydus image (optional)
In the above section we used a pre-converted Nydus image: `ghcr.io/dragonflyoss/image-service/nginx:nydus-latest`

You can also use [Nydusify](https://github.com/dragonflyoss/image-service/blob/master/docs/nydusify.md) to convert new Nydus images from OCI images.
```bash
sudo nerdctl run -d --restart=always -p 5000:5000 registry
sudo nydusify convert --fs-version 6 --source ubuntu --target localhost:5000/ubuntu-nydus
```
# 4. Verify result (optional)
## 4.1 Verify that the traffic for this download has passed through Dragonfly
```
pod_name=`kubectl -n dragonfly-system get pod -l component=dfdaemon --no-headers -o custom-columns=NAME:metadata.name`
kubectl -n dragonfly-system exec -it ${pod_name} -- sh -c 'grep "peer task done" /var/log/dragonfly/daemon/core.log'
```

The following log shows that Dragonfly can pull the image.
``` bash
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# pod_name=`kubectl -n dragonfly-system get pod -l component=dfdaemon --no-headers -o custom-columns=NAME:metadata.name`
root@iZj6c6r36jb1qak6ajdw4oZ:~/test/helm# kubectl -n dragonfly-system exec -it ${pod_name} -- sh -c 'grep "peer task done" /var/log/dragonfly/daemon/core.log'
Defaulted container "dfdaemon" out of: dfdaemon, wait-for-scheduler (init), mount-netns (init)
{"level":"info","ts":"2023-04-06 07:22:08.477","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 759ms","peer":"10.244.0.9-1-f48c0993-14aa-4436-93d1-f1cb790d7631","task":"023b961410d8776250215268f3569fa4ccb01bf1c557ca0e73888c4dd8c23ace","component":"PeerTask","trace":"7dd6c5401af251265458dd6ab2171bad"}
{"level":"info","ts":"2023-04-06 07:22:08.506","caller":"peer/peertask_conductor.go:1330","msg":"peer task done, cost: 860ms","peer":"10.244.0.9-1-747ae0c6-72fc-4f61-af55-931cad58e1a7","task":"39e00f986b2a2dbe0010c94e426596531497887ab15c266803334a464f84210e","component":"PeerTask","trace":"45257d1995c11cf46a1d43aa66b16c60"}
```
## 5. Conclusion
**So far, you have deployed Dragonfly & Nydus in the test environment. The deployment in the production environment needs further configuration. Please refer to the official documentation:**

- [https://d7y.io/docs/](https://d7y.io/docs/)

- [https://github.com/dragonflyoss/image-service#documentation](https://github.com/dragonflyoss/image-service#documentation)
# Remark
## Configuration on [Alibaba Cloud ACK](https://www.alibabacloud.com/product/kubernetes)
Since the environment of ACK is different from that of Kind, it is necessary to additionally configure Dragonfly's storage volume declaration with the following parameters in section 2.1
```
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
